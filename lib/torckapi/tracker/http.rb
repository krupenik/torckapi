require 'net/http'
require 'torckapi/tracker/base'

module Torckapi
  module Tracker

    class HTTP < Base
      # (see Base#announce)
      def announce info_hash
        super info_hash
        Torckapi::Response::Announce.from_http(info_hash, perform_request(url_for(@url.dup, Announce, info_hash)))
      end

      # (see Base#scrape)
      def scrape info_hashes=[]
        super info_hashes
        Torckapi::Response::Scrape.from_http(perform_request(url_for(@url.dup, Scrape, info_hashes)))
      end

      private

      REQUEST_ACTIONS = [Announce = 1, Scrape = 2].freeze

      def initialize url, options={}
        super url, options
        @url.query ||= ""
      end

      def url_for url, action, data
        url.query += info_hash_params [*data]
        url.path.gsub!(/announce/, 'scrape') if Scrape == action
        url
      end

      def perform_request url
        begin
          Net::HTTP.get(url)
        rescue Errno::ECONNRESET, Errno::ETIMEDOUT, Timeout::Error
          raise CommunicationFailedError
        end
      end

      def info_hash_params info_hashes
        info_hashes.map { |i| "info_hash=%s" % URI.encode([i].pack('H*')) }.join('&')
      end
    end
  end
end
