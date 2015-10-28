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
      expect(@http_tracker.instance_variable_get(:@options)).to \
        eql({:timeout=>15, :tries=>2})
    end

    it "should not allow any protocols except HTTP or UDP" do
      expect { Torckapi.tracker("https://xxx.com/") }.to \
        raise_error(Torckapi::Tracker::InvalidSchemeError)
    end
  end

  describe "#announce" do
    it "method should exist" do
      expect(@http_tracker).to respond_to(:announce)
    end

    it "require at least one argument" do
      expect { @http_tracker.announce }.to raise_error(ArgumentError)
    end

    context "should recieve response from" do
      it "http" do
        test_hash = "a1e14acedb90630243a950bd7aa204943eeca429"
        # File.write('spec/fixtures/a1e1...eca429.txt', "d8:completei833e10")
        http = double
        allow(Net::HTTP).to receive(:start).and_yield http
        allow(Net::HTTPResponse).to receive(:body) \
          .and_return(make_response(test_hash))

        allow(http).to \
          receive(:request).with(an_instance_of(Net::HTTP::Get)) \
            .and_return(Net::HTTPResponse)

        tr = @http_tracker.announce(test_hash)
        expect(tr.info_hash).to eql(test_hash)
        expect(tr.leechers).to eql(23)
        expect(tr.seeders).to eql(833)
      end

      it "udp" do
        test_hash = "ceafca487f6358eaf87b0ac6d1ae215c58ec3b83"
        # File.open("spec/fixtures/ceaf...8ec3b83.txt", "w:UTF-8") do |f|
        #   f.write ""
        # end
        # File.write('spec/fixtures/ceafca...58ec3b83.txt', "", "w:UTF-8")
        udp = double
        allow(UDPSocket).to receive(:new).and_return udp
        allow(udp).to receive(:send).and_return udp
        allow(udp).to receive(:recvfrom).with(65536) \
          .and_return([make_response(test_hash).force_encoding("ASCII-8BIT")])

        allow(SecureRandom).to receive(:random_bytes).with(20).and_call_original
        allow(SecureRandom).to receive(:random_bytes).with(4) \
          .and_return("\x1D\e\xFDp".force_encoding("ASCII-8BIT"))

        tr = @udp_tracker.announce(test_hash)
        expect(tr.info_hash).to eql(test_hash)
        expect(tr.leechers).to eql(5038)
        expect(tr.seeders).to eql(7244)
      end
    end
  end

end
