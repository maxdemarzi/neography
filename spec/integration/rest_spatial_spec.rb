require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "find the spatial plugin" do
    it "can get a description of the spatial plugin" do
      si = @neo.get_spatial
      si.should_not be_nil
      si["graphdb"]["addEditableLayer"].should_not be_nil
    end
  end

  describe "add a point layer" do
    it "can add a simple point layer" do
      pl = @neo.add_point_layer("restaurants") 
      pl.should_not be_nil
      pl.first["data"]["layer"].should == "restaurants"
      pl.first["data"]["geomencoder_config"].should == "lon:lat"
    end

    it "can add a simple point layer with lat and long" do
      pl = @neo.add_point_layer("coffee_shops", "latitude", "longitude") 
      pl.should_not be_nil
      pl.first["data"]["layer"].should == "coffee_shops"
      pl.first["data"]["geomencoder_config"].should == "longitude:latitude"
    end
    
  end

end