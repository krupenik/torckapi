require 'socket'
require 'timeout'
require 'securerandom'
require_relative 'base'

module Torckapi
  module Tracker
    
    # Implementation of http://www.bittorrent.org/beps/bep_0015.html
    class UDP < Base
      # connection_id is valid for 1 minute as per protocol
      CONNECTION_TIMEOUT = 60
      
      # @see Base#announce
      def announce info_hash
        super info_hash
        
        data = [[info_hash].pack('H*'), SecureRandom.random_bytes(20), [0, 0, 0, 0, 0, 0, -1, 0].pack('Q>3L>4s>')].join

        connect
        response_body = communicate(1, data)[0] # announce

        Torckapi::Response::Announce.from_udp info_hash, response_body[12..-1]
      end
      
      def scrape info_hashes=[]
        super info_hashes

        data = [*info_hashes].map { |i| [i].pack('H*') }.join
        
        connect
        response_body = communicate(2, data)[0] # scrape
        
        Torckapi::Response::Scrape.from_udp [*info_hashes], response_body[8..-1]
      end

      private

      def initialize *args
        super *args
      end
      
      def connect
        return if @connection_id && @communicated_at.to_i >= Time.now.to_i - CONNECTION_TIMEOUT
        
        @connection_id = [0x41727101980].pack('Q>')
        response_body = communicate(0)[0] # connect
        @connection_id = response_body[8..15]
      end
      
      def communicate action, data=nil
        @socket ||= UDPSocket.new
        
        transaction_id = SecureRandom.random_bytes(4)
        packet = [@connection_id, [action].pack('L>'), transaction_id, data].join

        tries = 0
        response = nil
        begin
          Timeout::timeout(@options[:timeout], CommunicationTimeoutError) do
            @socket.send(packet, 0, @url.host, @url.port)
            response = @socket.recvfrom(65536)
            raise TransactionIdMismatchError if transaction_id != response[0][4..7]
            @communicated_at = Time.now
          end
        rescue CommunicationTimeoutError
          retry if (tries += 1) <= @options[:tries] 
        end
        
        response
      end
    end
  end
end
