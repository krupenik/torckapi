require 'net/http'
require_relative 'base'

module Torckapi
  module Tracker

    class HTTP < Base

      # (see Base#announce)
      def announce info_hash
        super info_hash

        @url.query ||= ""
        @url.query += "info_hash=%s" % URI.encode([info_hash].pack('H*'))

        Torckapi::Response::Announce.from_http info_hash, Net::HTTP.get(@url)
      end

      # (see Base#scrape)
      def scrape info_hashes=[]
        super info_hashes

        raise NotImplementedError
      end

      private
    end
  end
end
