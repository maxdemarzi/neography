require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "get_relationship" do
    it "can get a relationship that exists" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      existing_relationships = @neo.get_node_relationships_to(new_node1, new_node2)
      existing_relationships[0].should_not be_nil
      existing_relationships[0].should have_key("self")
      existing_relationships[0]["self"].should == new_relationship["self"]
    end

    it "returns empty array if it tries to get a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      existing_relationship = @neo.get_node_relationships_to(new_node1, new_node3)
      existing_relationship.should be_empty
    end
  end

  describe "get_node_relationships" do
    it "can get a node's relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node2)
      relationships.should_not be_nil
      relationships[0]["start"].should == new_node1["self"]
      relationships[0]["end"].should == new_node2["self"]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
    end

    it "can get a node's multiple relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node1, new_node2, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node2)
      relationships.should_not be_nil
      relationships[0]["start"].should == new_node1["self"]
      relationships[0]["end"].should == new_node2["self"]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
      relationships[1]["start"].should == new_node1["self"]
      relationships[1]["end"].should == new_node2["self"]
      relationships[1]["type"].should == "enemies"
      relationships[1]["data"]["met"].should == "work"
      relationships[1]["data"]["since"].should == '10-2-2010'
    end

    it "can get all of a node's outgoing relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node2, new_node1, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node2, "out")
      relationships.should_not be_nil
      relationships[0]["start"].should == new_node1["self"]
      relationships[0]["end"].should == new_node2["self"]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
      relationships[1].should be_nil
    end

    it "can get all of a node's incoming relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node3, new_node1, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node3, "in")
      relationships.should_not be_nil
      relationships[0]["start"].should == new_node3["self"]
      relationships[0]["end"].should == new_node1["self"]
      relationships[0]["type"].should == "enemies"
      relationships[0]["data"]["met"].should == "work"
      relationships[0]["data"]["since"].should == '10-2-2010'
      relationships[1].should be_nil
    end

    it "can get a specific type of node relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("friends", new_node1, new_node3, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node2, "all", "friends")
      relationships.should_not be_nil
      relationships[0]["start"].should == new_node1["self"]
      relationships[0]["end"].should == new_node2["self"]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
      relationships[1].should be_nil
    end

    it "can get a specific type and direction of a node relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node1, new_node3, {"since" => '10-2-2010', "met" => "work"})
      new_relationship = @neo.create_relationship("enemies", new_node4, new_node1, {"since" => '10-3-2010', "met" => "gym"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node4, "in", "enemies")
      relationships.should_not be_nil
      relationships[0]["start"].should == new_node4["self"]
      relationships[0]["end"].should == new_node1["self"]
      relationships[0]["type"].should == "enemies"
      relationships[0]["data"]["met"].should == "gym"
      relationships[0]["data"]["since"].should == '10-3-2010'
      relationships[1].should be_nil
    end

    it "returns nil if there are no relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      relationships = @neo.get_node_relationships_to(new_node1, new_node2)
      relationships.should be_empty
    end
  end

end
