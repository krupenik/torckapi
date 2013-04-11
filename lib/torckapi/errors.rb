module Torckapi
  class Error < StandardError; end
  class InvalidInfohashError < Error; end

  module Tracker
    class Error < Torckapi::Error; end
    class InvalidSchemeError < Error; end
    class CommunicationTimeoutError < Error; end
  end
end