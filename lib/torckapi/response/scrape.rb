require 'torckapi/response/base'

module Torckapi
  module Response
    # Scrape response
    class Scrape < Base
      # @return [Hash<String, Hash>] scrape data
      attr_reader :data

      # Construct response object from udp response data
      # @param info_hashes [Array<String>] list of 40-char hexadecimal strings
      # @param data [String] UDP response data (omit action and transaction_id)
      # @return [Torckapi::Response::Scrape] response
      def self.from_udp info_hashes, data
        raise Torckapi::Tracker::MalformedResponseError if data.length != info_hashes.count * 12
        new Hash[info_hashes.zip(data.unpack('a12' * info_hashes.count).map { |i| counts_unpacked(i) })]
      end

      def self.from_http data
        bdecoded_data = bdecode_and_check data, 'files'
        new Hash[bdecoded_data['files'].map { |info_hash, counts| [info_hash.unpack('H*').join, counts_translated(counts) ]}]
      end

      private

      def self.counts_unpacked data
        counts_with_block(data, lambda { |data| data.unpack('L>3').map(&:to_i) })
      end

      def self.counts_translated data
        counts_with_block(data, lambda { |data| data.values_at("complete", "downloaded", "incomplete") })
      end

      def self.counts_with_block data, block
        Hash[[:seeders, :completed, :leechers].zip(block.call(data))]
      end

      def initialize data
        @data = data
      end
    end
  end
end
