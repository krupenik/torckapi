module Torckapi
  module Tracker

    # Public interface for torrent trackers
    class Base
      # Announce request
      # @param info_hash [String] 40-char hexadecimal string
      # @param peer_id [String] 20-byte binary string
      # @return [Torckapi::Response::Announce] a response object
      # @raise [Torckapi::InvalidInfohashError] when supplied with invalid info_hash
      # @raise [Torckapi::Tracker::CommunicationFailedError] when tracker haven't responded at all
      # @raise [Torckapi::Tracker::MalformedResponseError] when tracker returned junk
      def announce info_hash, peer_id=SecureRandom.random_bytes(20)
        raise Torckapi::InvalidInfohashError if info_hash !~ /\A[0-9a-f]{40}\z/i
      end

      # Scrape request
      # @param info_hashes [Array<String>] An array of 40-char hexadecimal strings
      # @return [Torckapi::Response::Scrape] a response object
      # @raise [Torckapi::InvalidInfohashError] when supplied with invalid info_hash
      # @raise [Torckapi::Tracker::CommunicationFailedError] when tracker haven't responded at all
      # @raise [Torckapi::Tracker::MalformedResponseError] when tracker returned junk
      def scrape info_hashes=[]
        raise Torckapi::InvalidInfohashError if info_hashes.any? { |i| i !~ /\A[0-9a-f]{40}\z/i }
      end

      private

      def initialize url, options={}
        @url = url
        @options = {timeout: 15, tries: 3}.merge(options)
      end
    end
  end
end
