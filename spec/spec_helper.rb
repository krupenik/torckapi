require "simplecov"
SimpleCov.start"

require 'torckapi'

RSpec.configure do |config|
  def fixture(filename)
    File.dirname(__FILE__) + '/fixtures/' + filename
  end

  def make_response(filename_or_string)
    open(fixture(filename_or_string + '.txt'), "r:UTF-8").read
  end

  def init_torckapi
    @http_tracker = Torckapi.tracker("http://localhost/")
    @udp_tracker = Torckapi.tracker("udp://localhost/")
  end
end
