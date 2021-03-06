require 'spec_helper'

describe Bucky::Geolocation do
  describe ".get_country" do
    {
      "202.162.73.2" => "NZ", # TradeMe IP
      "67.205.28.58" => "US", # one of our box
      "127.0.0.1" => "RD",
    }.each do |ip, country|
      it "returns the right country", :internet do
        expect(Bucky::Geolocation.get_country(ip)).to be_in [nil, "", country]
      end
    end
  end

  describe ".get_time_zone" do
    before do
      Fabricate(:country, alpha2: "NZ")
    end

    it "returns the right time zone" do
      expect(Bucky::Geolocation.get_time_zone("NZ")).to eq "Pacific/Auckland"
    end
  end

  describe ".get_address_form" do
    let(:fields) { %w(street state city zip) }
    let(:resource) do
      double(
        'class' => double(model_name: "resource"),
        localised_address: nil
      )
    end

    before do
      Fabricate(:country)
    end

    it "returns the right address fields" do
      form = Bucky::Geolocation.get_address_form("NZ", resource)

      expect(form).to include(*fields)
    end

    it "fallbacks to NZ if format not available for this country" do
      form = Bucky::Geolocation.get_address_form("KE", resource)

      expect(form).to include(*fields)
    end
  end

  describe ".get_geoip_info" do
    it "ignores bad responses" do
      geoip = double(request: double(response: double(success?: false, code: 0)))
      allow(Typhoeus).to receive(:get) { geoip }

      expect(Bucky::Geolocation.get_geoip_info("202.162.73.2")).to be_nil
    end
  end
end
