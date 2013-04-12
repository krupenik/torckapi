module Torckapi
  class Error < StandardError; end
  class InvalidInfohashError < Error; end

  module Tracker
    class Error < Torckapi::Error; end
    class InvalidSchemeError < Error; end
    class CommunicationError < Error; end
    class CommunicationFailedError < CommunicationError; end
    class CommunicationTimeoutError < CommunicationError; end
  end

  module Response
    class Error < Torckapi::Error; end
    class ArgumentError < Error; end
  end
end