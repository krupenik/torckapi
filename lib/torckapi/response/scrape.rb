module Torckapi
  module Response

    # Scrape response
    class Scrape
      # @return [Hash<String, Hash>] scrape data
      attr_reader :data

      # Construct response object from udp response data
      # @param info_hashes [Array<String>] list of 40-char hexadecimal strings
      # @param data [String] UDP response data (omit action and transaction_id)
      # @return [Torckapi::Response::Scrape] response
      def self.from_udp info_hashes, data
        raise Torckapi::ArgumentError, "data does not match info_hashes" if data.length != info_hashes.count * 12
        new Hash[info_hashes.zip(data.unpack('a12' * info_hashes.count).map { |i| peers_hash(i) })]
      end

      private

      def self.peers_hash data
        Hash[[:seeders, :completed, :leechers].zip(data.unpack('L>3').map(&:to_i))]
      end

      def initialize data
        @data = data
      end
    end
  end
end
