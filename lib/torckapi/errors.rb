module Torckapi
  Error = Class.new(StandardError)
  InvalidInfohashError = Class.new(Error)

  module Tracker
    Error = Class.new(Torckapi::Error)
    InvalidSchemeError = Class.new(Error)
    ConnectionFailedError Class.new(Error)
    CommunicationError = Class.new(Error)
    CommunicationFailedError = Class.new(CommunicationError)
    CommunicationTimeoutError = Class.new(CommunicationError)
    MalformedResponseError = Class.new(Error)
    TransactionIdMismatchError = Class.new(CommunicationError)
  end
end
