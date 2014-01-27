require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "the spatial plugin works" do
    it "better work" do
      @neo.create_spatial_index("geom", "point", "lat", "lon")
      node = @neo.create_node({:lat => 60.1, :lon => 15.2})
      added = @neo.add_node_to_index("geom", "dummy", "dummy", node)
      existing_node = @neo.execute_query("start node = node:geom('withinDistance:[60.0,15.0, 100.0]') return node")
      puts existing_node.inspect
    end

    it "can find a geometry in a bounding box using cypher" do
      properties = {:lat => 60.1, :lon => 15.2}
      @neo.create_spatial_index("geombbcypher", "point", "lat", "lon")
      node = @neo.create_node(properties)
      added = @neo.add_node_to_index("geombbcypher", "dummy", "dummy", node)
      existing_node = @neo.execute_query("start node = node:geombbcypher('withinDistance:[60.0,15.0, 100.0]') return node")
      puts existing_node.inspect
      existing_node["data"][0][0]["data"].should_not be_empty
      existing_node["data"][0][0]["data"]["lat"].should == properties[:lat]
      existing_node["data"][0][0]["data"]["lon"].should == properties[:lon]
    end

  end
end