require 'bencode'

module Torckapi
  module Response
    class Base
      protected

      def self.bdecode_and_check(data, key)
        begin
          bdecoded_data = BEncode.load(data, :ignore_trailing_junk => true)
        rescue BEncode::DecodeError
          raise Torckapi::Tracker::MalformedResponseError, "Can't decode '%s'" % data
        end

        raise Torckapi::Tracker::MalformedResponseError, "bdecoded data: '%s'" % bdecoded_data + " didn't contain key: '%s'" % key unless bdecoded_data.is_a? Hash and bdecoded_data.has_key? key

        bdecoded_data
      end
    end
  end
end
