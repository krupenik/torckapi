require 'ipaddr'

module Torckapi
  module Response
    class Announce
      # @!attribute [r] info_hash
      #   @return [String] 40-char hexadecimal string
      # @!attribute [r] leechers
      #   @return [Fixnum] number of leechers
      # @!attribute [r] peers
      #   @return [Array<IPAddr, Fixnum>] list of peers
      # @!attribute [r] seeders
      #   @return [Fixnum] number of seeders
      attr_reader :info_hash, :leechers, :peers, :seeders

      # Construct response object from udp response data
      # @param info_hash [String] 40-char hexadecimal string
      # @param data [String] UDP response data (omit action and transaction_id)
      # @return [Torckapi::Response::Announce] response
      def self.from_udp info_hash, data
        leechers, seeders = data[0..7].unpack('L>2')
        peers = data[8..-1].unpack('a6' * (leechers + seeders)).map { |i| [IPAddr.ntop(i[0..3]), i[4..5].unpack('S>')[0]] }
      
        new info_hash, leechers, seeders, peers
      end
      
      private
      
      def initialize info_hash, leechers, seeders, peers
        @info_hash = info_hash
        @leechers = leechers
        @seeders = seeders
        @peers = peers
      end
    end
  end
end
