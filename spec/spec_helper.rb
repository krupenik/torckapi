require 'torckapi'

require "codeclimate-test-reporter"
ENV['CODECLIMATE_REPO_TOKEN'] = "3004a7854020df72de40cef4c1f7fc1992ca1969b5420f548df7f4ab6a9b881b"
CodeClimate::TestReporter.start

RSpec.configure do |config|
  def fixture(filename)
    File.dirname(__FILE__) + '/fixtures/' + filename
  end

  def make_response(xml_filename_or_string)
    if xml_filename_or_string !~ /</
      xml_filename_or_string = open(fixture(xml_filename_or_string + '.xml')).read
    end

    Lastfm::Response.new(xml_filename_or_string)
  end

  def init_torckapi
    @http_tracker = Torckapi.tracker("http://xxx.com/")
    @udp_tracker = Torckapi.tracker("udp://xxx.com/")
  end
end