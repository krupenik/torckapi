require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'torckapi'

RSpec.configure do |config|
  def fixture(filename)
    File.dirname(__FILE__) + '/fixtures/' + filename
  end

  def make_response(filename_or_string)
    if filename_or_string !~ /</
      filename_or_string = open(fixture(filename_or_string + '.xml')).read
    end

    Response.new(filename_or_string)
  end

  def init_torckapi
    @http_tracker = Torckapi.tracker("http://xxx.com/")
    @udp_tracker = Torckapi.tracker("udp://xxx.com/")
  end
end