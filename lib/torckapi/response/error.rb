module Torckapi
  module Response
    class Error
      # @!attribute [r] info_hash
      #   @return [String] 40-char hexadecimal string
      # @!attribute [r] message
      #   @return [String] error description
      attr_reader :info_hash, :message

      # Construct response object from udp response data
      # @param info_hash [String] 40-char hexadecimal string
      # @param data [String] UDP response data (omit action and transaction_id)
      # @return [Torckapi::Response::Error] response
      def self.from_udp info_hash, data
        new info_hash, data
      end

      private

      def initialize info_hash, message
        @info_hash = info_hash
        @message = message
      end
    end
  end
end
