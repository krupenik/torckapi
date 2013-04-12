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
        raise ArgumentError, "info_hashes cannot be nil" if info_hashes.nil?
        raise ArgumentError, "data cannot be nil" if data.nil?
        new Hash[info_hashes.zip(data.unpack('a12' * (info_hashes.count)).map { |i| Hash[[:seeders, :completed, :leechers].zip i.unpack('L>3').map(&:to_i)] })]
      end

      private

      def initialize data
        @data = data
      end
    end
  end
end
