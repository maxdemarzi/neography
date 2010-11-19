require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do

  describe "get path" do
    it "can get a path between two nodes" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2005', "met" => "college"})
      path = Neography::Rest.get_path(new_node1[:id], new_node2[:id], {"type"=> "friends", "direction" => "out"})
      path["start"].should == new_node1["self"]
      path["end"].should == new_node2["self"]
      path["nodes"].should == [new_node1["self"], new_node2["self"]]
    end

    it "can get the shortest path between two nodes" do
      pending
    end

    it "can get a simple path between two nodes" do
      pending
    end

    it "can get a path between two nodes of max depth 3" do
      pending
    end

    it "can get a path between two nodes of a specific relationship" do
      pending
    end
  end

  describe "get paths" do
    it "can get the shortest paths between two nodes" do
      pending
    end

    it "can get all paths between two nodes" do
      pending
    end

    it "can get all simple paths between two nodes" do
      pending
    end

    it "can get paths between two nodes of max depth 3" do
      pending
    end

    it "can get paths between two nodes of a specific relationship" do
      pending
    end

  end


end