require 'socket'
require 'timeout'
require 'securerandom'
require 'torckapi/tracker/base'

module Torckapi
  module Tracker
    # Implementation of http://www.bittorrent.org/beps/bep_0015.html
    class UDP < Base
      def announce info_hash, peer_id=SecureRandom.random_bytes(20)
        super
        perform_request Announce, announce_request_data(info_hash, peer_id), info_hash
      end

      def scrape info_hashes=[]
        super
        perform_request Scrape, scrape_request_data(info_hashes), info_hashes
      end

      private

      CONNECTION_TIMEOUT = 60
      REQUEST_ACTIONS = [Connect = 0, Announce = 1, Scrape = 2].freeze
      RESPONSE_CLASSES = [nil, Torckapi::Response::Announce, Torckapi::Response::Scrape, Torckapi::Response::Error].freeze
      RESPONSE_MIN_LENGTHS = [16, 20, 8, 8].freeze
      RESPONSE_CODES = 0..RESPONSE_CLASSES.length

      def initialize url, options={}
        super
        @state = nil
        @connection_id = nil
        @communicated_at = 0
      end

      def connected?
        @connection_id && @communicated_at.to_i >= Time.now.to_i - CONNECTION_TIMEOUT
      end

      def connecting?
        @state == :connecting
      end

      def perform_request action, data, *args
        response = communicate action, data

        RESPONSE_CLASSES[response[:code]].from_udp(*args, response[:data])
      end

      def announce_request_data info_hash, peer_id
        [[info_hash].pack('H*'), peer_id, [0, 0, 0, 0, 0, 0, -1, 0].pack('Q>3L>4S>')].join
      end

      def scrape_request_data info_hashes
        info_hashes.map { |i| [i].pack('H*') }.join
      end

      def connect
        return if connected? || connecting?

        @state, @connection_id = :connecting, [0x041727101980].pack('Q>')
        response = communicate Connect
        @state, @connection_id = nil, response[:data]
      end

      def communicate action, data=nil
        @socket ||= UDPSocket.new

        tries = 0
        response = nil

        begin
          timeout = @options[:timeout] * (2 ** tries)
          connect
          transaction_id = SecureRandom.random_bytes(4)
          packet = [@connection_id, [action].pack('L>'), transaction_id, data].join

          Timeout::timeout(timeout, CommunicationTimeoutError) do
            @socket.send(packet, 0, @url.host, @url.port)
            response = process_response @socket.recvfrom(65536)[0], transaction_id
            @communicated_at = Time.now
          end
        rescue CommunicationTimeoutError, LittleEndianResponseError => e
          retry if (tries += 1) <= @options[:tries]
        end

        raise CommunicationFailedError unless response

        response
      end

      def process_response response, transaction_id
        check_transaction_id response, transaction_id
        response_code = extract_response_code response
        check_response_length response, response_code

        {code: response_code, data: response[8..-1]}
      end

      def check_transaction_id response, transaction_id
        raise TransactionIdMismatchError, response if transaction_id != response[4..7]
      end

      def extract_response_code response
        response_code, response_code_le = [response[0..3]].flat_map { |x| [x.unpack('L>')[0], x.unpack('L<')[0]] }

        unless RESPONSE_CODES.include?(response_code)
          raise (RESPONSE_CODES.include?(response_code_le) ? LittleEndianResponseError : MalformedResponseError), response
        end

        response_code
      end

      def check_response_length response, response_code
        raise MalformedResponseError, response if RESPONSE_MIN_LENGTHS[response_code] > response.length
      end
    end
  end
end
