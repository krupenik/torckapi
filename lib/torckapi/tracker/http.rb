require 'net/http'
require 'torckapi/tracker/base'

module Torckapi
  module Tracker

    class HTTP < Base

      # (see Base#announce)
      def announce info_hash
        super info_hash
        @url.query += info_hash_params [info_hash]

        Torckapi::Response::Announce.from_http info_hash, Net::HTTP.get(@url)
      end

      # (see Base#scrape)
      def scrape info_hashes=[]
        super info_hashes
        @url.query += info_hash_params info_hashes
        @url.path.gsub!(/announce/, 'scrape')

        Torckapi::Response::Scrape.from_http Net::HTTP.get(@url)
      end

      private

      def initialize url, options={}
        super url, options

        @url.query ||= ""
      end

      def info_hash_params info_hashes
        info_hashes.map { |i| "info_hash=%s" % URI.encode([i].pack('H*')) }.join('&')
      end
    end
  end
end
