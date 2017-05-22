require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Torckapi do

  before do
    init_torckapi

    http = double
    allow(Net::HTTP).to receive(:start).and_yield http
    allow(http).to \
      receive(:request).with(an_instance_of(Net::HTTP::Get)) \
        .and_return(Net::HTTPResponse)

    @udp = double
    allow(UDPSocket).to receive(:new).and_return @udp
    allow(@udp).to receive(:send).and_return @udp
    allow(IO).to receive(:select).and_return true

    allow(SecureRandom).to receive(:random_bytes).and_call_original
  end

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
      expect { Torckapi.tracker("https://localhost/") }.to \
        raise_error(Torckapi::Tracker::InvalidSchemeError)
    end
  end

  describe "#announce" do
    it "method should exist" do
      expect(@http_tracker).to respond_to(:announce)
      expect(@udp_tracker).to respond_to(:announce)
    end

    it "should decline not valid hashes" do
      expect {
        @http_tracker.announce(SecureRandom.hex(19))
      }.to raise_error(Torckapi::InvalidInfohashError)
      expect {
        @http_tracker.announce(SecureRandom.hex(21))
      }.to raise_error(Torckapi::InvalidInfohashError)
      expect {
        @udp_tracker.announce(SecureRandom.hex(19))
      }.to raise_error(Torckapi::InvalidInfohashError)
      expect {
        @udp_tracker.announce(SecureRandom.hex(21))
      }.to raise_error(Torckapi::InvalidInfohashError)
    end

    context "should recieve response from" do
      it "http" do
        test_hash = SecureRandom.hex(20)
        # File.write('spec/fixtures/udp_scrape.txt', "")

        allow(Net::HTTPResponse).to receive(:body)
          .and_return(make_response("http_announce"))

        tr = @http_tracker.announce(test_hash)
        expect(tr.info_hash).to eql(test_hash)
        expect(tr.leechers).to eql(23)
        expect(tr.seeders).to eql(833)

      end

      it "udp" do
        test_hash = SecureRandom.hex(20)
        # File.open("spec/fixtures/ceaf...8ec3b83.txt", "w:UTF-8") do |f|
        #   f.write ""
        # end
        # File.write('spec/fixtures/ceafca...58ec3b83.txt', "", "w:UTF-8")

        allow(@udp).to receive(:recvfrom).with(65536)
          .and_return([make_response("udp_announce")
            .force_encoding("ASCII-8BIT")])
        allow(SecureRandom).to receive(:random_bytes).with(4)
          .and_return("\x1D\e\xFDp".force_encoding("ASCII-8BIT"))

        tr = @udp_tracker.announce(test_hash)
        expect(tr.info_hash).to eql(test_hash)
        expect(tr.leechers).to eql(5038)
        expect(tr.seeders).to eql(7244)
      end
    end
  end

  describe "#scrape" do
    it "method should exist" do
      expect(@http_tracker).to respond_to(:scrape)
      expect(@udp_tracker).to respond_to(:scrape)
    end

    it "should decline not valid hashes" do
      expect {
        @http_tracker.scrape([SecureRandom.hex(19), SecureRandom.hex(21)])
      }.to raise_error(Torckapi::InvalidInfohashError)
      expect {
        @udp_tracker.scrape([SecureRandom.hex(19), SecureRandom.hex(21)])
      }.to raise_error(Torckapi::InvalidInfohashError)
    end

    context "should recieve response from" do
      before do
        @test_hash = ["573f1b2f2d11dcc06eaa9b322754312c15bb9b25",
                     "bce28cae76f27bb36d5380e7dc1090a109bd366a"]
      end

      it "http" do
        allow(Net::HTTPResponse).to receive(:body) \
          .and_return(make_response("http_scrape"))

        tr = @http_tracker.scrape(@test_hash)
        expect(tr).to respond_to(:data)

        tr = tr.data
        expect(tr).to have_key(@test_hash[0])
        expect(tr).to have_key(@test_hash[1])
        expect(tr[@test_hash[0]][:seeders]).to eql(1893)
        expect(tr[@test_hash[0]][:leechers]).to eql(242)
        expect(tr[@test_hash[0]][:completed]).to eql(10)
      end
      it "udp" do
        allow(@udp).to receive(:recvfrom).with(65536)
          .and_return([make_response("udp_scrape")
            .force_encoding("ASCII-8BIT")])
        allow(SecureRandom).to receive(:random_bytes).with(4)
          .and_return("\xAF+\x97\xEA".force_encoding("ASCII-8BIT"))
        tr = @udp_tracker.scrape(@test_hash)

        expect(tr).to respond_to(:data)

        tr = tr.data
        expect(tr).to have_key(@test_hash[0])
        expect(tr).to have_key(@test_hash[1])
        expect(tr[@test_hash[0]][:seeders]).to eql(26)
        expect(tr[@test_hash[0]][:leechers]).to eql(6)
        expect(tr[@test_hash[0]][:completed]).to eql(160)

      end
    end
  end

end
