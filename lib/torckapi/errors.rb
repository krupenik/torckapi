module Torckapi
  class Error < StandardError; end
  class InvalidInfohashError < Error; end
  class ArgumentError < Error; end

  module Tracker
    class Error < Torckapi::Error; end
    class InvalidSchemeError < Error; end
    class ConnectionFailedError < Error; end
    class CommunicationError < Error; end
    class CommunicationFailedError < CommunicationError; end
    class CommunicationTimeoutError < CommunicationError; end
    class MalformedResponseError < CommunicationError; end
    class TransactionIdMismatchError < CommunicationError; end
  end
end