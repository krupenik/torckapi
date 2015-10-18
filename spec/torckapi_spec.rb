require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Torckapi do

  before { init_torckapi }

  describe "#tracker" do
    it "method should exist" do
      expect(Torckapi).to respond_to(:tracker)
    end

    it "require at least one argument" do
      expect { Torckapi.tracker }.to raise_error(ArgumentError)
      expect(@http_tracker).to be_truthy
    end

    it "should set default options" do
      expect(@http_tracker.instance_variable_get(:@options)).to eql({:timeout=>15, :tries=>7})
    end

    it "should not allow any protocols except HTTP or UDP" do
      expect { Torckapi.tracker("https://xxx.com/") }.to raise_error(Torckapi::Tracker::InvalidSchemeError)
    end
  end

end
