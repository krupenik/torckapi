module Torckapi
  class Error < StandardError; end
  class InvalidInfohashError < Error; end

  module Tracker
    class Error < Torckapi::Error; end
    class InvalidSchemeError < Error; end
    class ConnectionFailedError < Error; end
    class CommunicationError < Error; end
    class CommunicationTimeoutError < CommunicationError; end
    class CommunicationFailedError < CommunicationError; end
    class AnnounceFailedError < CommunicationFailedError; end
    class ScrapeFailedError < CommunicationFailedError; end
  end

  module Response
    class Error < Torckapi::Error; end
    class ArgumentError < Error; end
  end
end