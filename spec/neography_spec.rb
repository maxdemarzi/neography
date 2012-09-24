require 'spec_helper'

describe Neography do

  describe "::configure" do

    it "returns the same configuration" do
      Neography.configuration.should == Neography.configuration
    end

    it "returns the Config" do
      Neography.configuration.should be_a Neography::Config
    end

    it "yields the configuration" do
      Neography.configure do |config|
        config.should == Neography.configuration
      end
    end

  end

end
