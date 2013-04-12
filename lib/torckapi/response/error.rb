module Torckapi
  module Response
    class Error
      # @!attribute [r] info_hash
      #   @return [String] 40-char hexadecimal string
      # @!attribute [r] info_hashes
      #   @return [Array<String>] an array of 40-char hexadecimal strings
      # @!attribute [r] message
      #   @return [String] error description
      attr_reader :info_hash, :info_hashes, :message

      # Construct response object from udp response data
      # @param info_hash [String] 40-char hexadecimal string
      # @param data [String] UDP response data (omit action and transaction_id)
      # @return [Torckapi::Response::Error] response
      def self.from_udp info_hashes, data
        new info_hashes, data
      end

      def info_hash
        info_hashes[0]
      end

      private

      def initialize info_hashes, message
        @info_hashes = [*info_hashes]
        @message = message
      end
    end
  end
end
