require 'socket'
require 'timeout'
require 'securerandom'
require 'torckapi/tracker/base'

module Torckapi
  module Tracker
    # Implementation of http://www.bittorrent.org/beps/bep_0015.html
    class UDP < Base
      def announce info_hash, peer_id=SecureRandom.random_bytes(20)
        super info_hash
        perform_request Announce, announce_request_data(info_hash, peer_id), info_hash
      end

      def scrape info_hashes=[]
        super info_hashes
        perform_request Scrape, scrape_request_data(info_hashes), info_hashes
      end

      private

      CONNECTION_TIMEOUT = 60
      REQUEST_ACTIONS = [Connect = 0, Announce = 1, Scrape = 2].freeze
      RESPONSE_CLASSES = [nil, Torckapi::Response::Announce, Torckapi::Response::Scrape, Torckapi::Response::Error].freeze
      RESPONSE_MIN_LENGTHS = [16, 20, 8, 8].freeze

      def perform_request action, data, *args
        connect
        response = communicate action, data

        RESPONSE_CLASSES[response[:type]].from_udp(*args, response[:data])
      end

      def announce_request_data info_hash, peer_id
        [[info_hash].pack('H*'), peer_id, [0, 0, 0, 0, 0, 0, -1, 0].pack('Q>3L>4S>')].join
      end

      def scrape_request_data info_hashes
        info_hashes.map { |i| [i].pack('H*') }.join
      end

      def connect
        return if @connection_id && @communicated_at.to_i >= Time.now.to_i - CONNECTION_TIMEOUT

        @connection_id = [0x041727101980].pack('Q>')
        response = communicate Connect
        @connection_id = response[:data]
      end

      def communicate action, data=nil
        @socket ||= UDPSocket.new

        transaction_id = SecureRandom.random_bytes(4)
        tries = 0
        response = nil

        begin
          packet = [@connection_id, [action].pack('L>'), transaction_id, data].join

          Timeout::timeout(@options[:timeout], CommunicationTimeoutError) do
            @socket.send(packet, 0, @url.host, @url.port)
            response = parse_response @socket.recvfrom(65536), transaction_id
            @communicated_at = Time.now
          end
        rescue CommunicationTimeoutError
          retry if (tries += 1) <= @options[:tries]
        end

        raise CommunicationFailedError unless response

        response
      end

      def parse_response data, transaction_id
        response, sender_addrinfo = data

        response_type = response[0..3].unpack('L>')[0]

        raise TransactionIdMismatchError, response.inspect if transaction_id != response[4..7]
        raise MalformedResponseError, response.inspect if RESPONSE_MIN_LENGTHS[response_type] > response.length

        {type: response_type, data: response[8..-1]}
      end
    end
  end
end
