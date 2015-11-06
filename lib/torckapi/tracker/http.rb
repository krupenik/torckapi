require 'net/http'
require 'torckapi/tracker/base'

module Torckapi
  module Tracker

    class HTTP < Base
      # (see Base#announce)
      def announce(info_hash)
        super
        Torckapi::Response::Announce.from_http(info_hash, perform_request(url_for(@url.dup, Announce, info_hash)))
      end

      # (see Base#scrape)
      def scrape(info_hashes = [])
        super
        Torckapi::Response::Scrape.from_http(perform_request(url_for(@url.dup, Scrape, info_hashes)))
      end

      private

      REQUEST_ACTIONS = [Announce = 1, Scrape = 2].freeze

      def initialize(url, options = {})
        super
        @url.query ||= ""
      end

      def url_for(url, action, data)
        url.query += info_hash_params [*data]
        url.path.gsub!(/announce/, 'scrape') if Scrape == action
        url
      end

      def perform_request(url)

        tries = 0

        begin
          timeout = @options[:timeout]
          request = Net::HTTP::Get.new(url.to_s)
          Net::HTTP.start(url.host, url.port, open_timeout: timeout, read_timeout: timeout) do |http|
            http.request(request).body
          end
        rescue Errno::ECONNRESET, Errno::ETIMEDOUT, Timeout::Error, Errno::ECONNREFUSED
          if (tries += 1) <= @options[:tries]
            retry # backs up to just after the "begin"
          else
            raise CommunicationFailedError
          end
        end
      end

      def info_hash_params(info_hashes)
        info_hashes.map { |i| "info_hash=%s" % URI.encode([i].pack('H*')) }.join('&')
      end
    end
  end
end
