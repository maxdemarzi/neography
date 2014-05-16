require 'spec_helper'

describe Neography do

  describe "::configure" do

    it "returns the same configuration" do
      expect(Neography.configuration).to eq(Neography.configuration)
    end

    it "returns the Config" do
      expect(Neography.configuration).to be_a Neography::Config
    end

    it "yields the configuration" do
      Neography.configure do |config|
        expect(config).to eq(Neography.configuration)
      end
    end

  end

end
