require 'ipaddr'
require 'torckapi/response/base'

module Torckapi
  module Response
    # Announce response
    class Announce < Base
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
      def self.from_udp(info_hash, data)
        new info_hash, *data[4..11].unpack('L>2'), peers_from_compact(data[12..-1] || '')
      end

      # Construct response object from http response data
      # @param info_hash [String] 40-char hexadecimal string
      # @param data [String] HTTP response data (bencoded)
      # @return [Torckapi::Response::Announce] response
      # @raise [Torckapi::Tracker::MalformedResponseError]
      def self.from_http(info_hash, data)
        bdecoded_data = bdecode_and_check data, 'peers'
        new info_hash, *bdecoded_data.values_at('incomplete', 'complete'), peers_from_compact(bdecoded_data['peers'])
      end

      private

      def initialize(info_hash, leechers, seeders, peers)
        @info_hash = info_hash
        @leechers = leechers
        @seeders = seeders
        @peers = peers
      end

      def self.peers_from_compact(data)
        # ipv4 address + tcp/udp port = 6 bytes
        data.unpack('a6' * (data.length / 6)).map { |i| [IPAddr.ntop(i[0..3]), i[4..5].unpack('S>')[0]] }
      end
    end
  end
end
