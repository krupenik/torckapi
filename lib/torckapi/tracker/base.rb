module Torckapi
  module Tracker
    
    # Public interface for torrent trackers
    class Base
      # Announce Request
      # @param info_hash [String] 40-char hexadecimal string
      # @return [Torckapi::AnnounceResponse] a response object
      def announce info_hash
        raise Torckapi::InvalidInfohashError if info_hash !~ /\A[0-9a-f]{40}\z/i
      end

      # Scrape Request
      # @param info_hashes [String, Array<String>] A single 40-char hexadecimal string or an array of those
      # @return [Torckapi::ScrapeResponse] a response object
      def scrape info_hashes=[]
        raise Torckapi::InvalidInfohashError if [*info_hashes].any? { |i| i !~ /\A[0-9a-f]{40}\z/i }
      end
      
      private
      
      def initialize url, options={}
        @url = url
        @options = {timeout: 15, tries: 3}.merge(options)
      end
    end
  end
end
