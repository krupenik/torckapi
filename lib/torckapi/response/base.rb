require 'bencode'

module Torckapi
  module Response
    class Base
      protected

      def self.bdecode_and_check data, key
        begin
          bdecoded_data = BEncode.load(data)
        rescue BEncode::DecodeError
          raise Torckapi::Tracker::MalformedResponseError
        end

        raise Torckapi::Tracker::MalformedResponseError unless bdecoded_data.is_a? Hash and bdecoded_data.has_key? key

        bdecoded_data
      end
    end
  end
end
