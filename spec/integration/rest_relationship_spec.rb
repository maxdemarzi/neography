require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "create_relationship" do
    it "can create an empty relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      new_relationship["start"].should_not be_nil
      new_relationship["end"].should_not be_nil
    end

    it "can create a relationship with one property" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010'})
      new_relationship["data"]["since"].should == '10-1-2010'
    end

    it "can create a relationship with more than one property" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      new_relationship["data"]["since"].should == '10-1-2010'
      new_relationship["data"]["met"].should == "college"
    end
  end

  describe "get_relationship" do
    it "can get a relationship that exists" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      existing_relationship = @neo.get_relationship(new_relationship)
      existing_relationship.should_not be_nil
      existing_relationship.should have_key("self")
      existing_relationship["self"].should == new_relationship["self"]
    end

    it "returns nil if it tries to get a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      existing_relationship = @neo.get_relationship(fake_relationship)
      existing_relationship.should be_nil
    end
  end

  describe "set_relationship_properties" do
    it "can set a relationship's properties" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      @neo.set_relationship_properties(new_relationship, {"since" => '10-1-2010', "met" => "college"})
      @neo.set_relationship_properties(new_relationship, {"roommates" => "no"})
      relationship_properties = @neo.get_relationship_properties(new_relationship)
      relationship_properties["since"].should == '10-1-2010'
      relationship_properties["met"].should == "college"
      relationship_properties["roommates"].should == "no"
    end

    it "it fails to set properties on a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      @neo.set_relationship_properties(fake_relationship, {"since" => '10-1-2010', "met" => "college"})
      relationship_properties = @neo.get_relationship_properties(fake_relationship)
      relationship_properties.should be_nil
    end
  end

  describe "reset_relationship_properties" do
    it "can reset a relationship's properties" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      @neo.set_relationship_properties(new_relationship, {"since" => '10-1-2010', "met" => "college"})
      @neo.reset_relationship_properties(new_relationship, {"roommates" => "no"})
      relationship_properties = @neo.get_relationship_properties(new_relationship)
      relationship_properties["since"].should be_nil
      relationship_properties["met"].should be_nil
      relationship_properties["roommates"].should == "no"
    end

    it "it fails to reset properties on a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      @neo.reset_relationship_properties(fake_relationship, {"since" => '10-1-2010', "met" => "college"})
      relationship_properties = @neo.get_relationship_properties(fake_relationship)
      relationship_properties.should be_nil
    end
  end

  describe "get_relationship_properties" do
    it "can get all of a relationship's properties" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      relationship_properties = @neo.get_relationship_properties(new_relationship)
      relationship_properties["since"].should == '10-1-2010'
      relationship_properties["met"].should == "college"
    end

    it "can get some of a relationship's properties" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college", "roommates" => "no"})
      relationship_properties = @neo.get_relationship_properties(new_relationship, ["since", "roommates"])
      relationship_properties["since"].should == '10-1-2010'
      relationship_properties["met"].should be_nil
      relationship_properties["roommates"].should == "no"
    end

    it "returns nil if it gets the properties on a relationship that does not have any" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      relationship_properties = @neo.get_relationship_properties(new_relationship)
      relationship_properties.should be_nil
    end

    it "returns nil if it tries to get some of the properties on a relationship that does not have any" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      relationship_properties = @neo.get_relationship_properties(new_relationship, ["since", "roommates"])
      relationship_properties.should be_nil
    end

    it "returns nil if it fails to get properties on a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      relationship_properties = @neo.get_relationship_properties(fake_relationship)
      relationship_properties.should be_nil
    end
  end

  describe "remove_relationship_properties" do
    it "can remove a relationship's properties" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      @neo.remove_relationship_properties(new_relationship)
      @neo.get_relationship_properties(new_relationship).should be_nil
    end

    it "returns nil if it fails to remove the properties of a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      @neo.remove_relationship_properties(fake_relationship).should be_nil
      @neo.get_relationship_properties(fake_relationship).should be_nil
    end

    it "can remove a specific relationship property" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      @neo.remove_relationship_properties(new_relationship, "met")
      relationship_properties = @neo.get_relationship_properties(new_relationship, ["met", "since"])
      relationship_properties["met"].should be_nil
      relationship_properties["since"].should == '10-1-2010'
    end

    it "can remove more than one relationship property" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college", "roommates" => "no"})
      @neo.remove_relationship_properties(new_relationship, ["met", "since"])
      relationship_properties = @neo.get_relationship_properties(new_relationship, ["since", "met", "roommates"])
      relationship_properties["met"].should be_nil
      relationship_properties["since"].should be_nil
      relationship_properties["roommates"].should == "no"
    end
  end

  describe "delete_relationship" do
    it "can delete an existing relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      @neo.delete_relationship(new_relationship)
      relationships = @neo.get_node_relationships(new_node1)
      relationships.should be_nil
    end

    it "returns nil if it tries to delete a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      existing_relationship = @neo.delete_relationship(fake_relationship)
      existing_relationship.should be_nil
    end

    it "returns nil if it tries to delete a relationship that has already been deleted" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      existing_relationship = @neo.delete_relationship(new_relationship)
      existing_relationship.should be_nil
      existing_relationship = @neo.delete_relationship(new_relationship)
      existing_relationship.should be_nil
    end
  end

  describe "get_node_relationships" do
    it "can get a node's relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      relationships = @neo.get_node_relationships(new_node1)
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
      new_relationship = @neo.create_relationship("enemies", new_node1, new_node3, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships(new_node1)
      relationships.should_not be_nil
      relationships[0]["start"].should == new_node1["self"]
      relationships[0]["end"].should == new_node2["self"]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
      relationships[1]["start"].should == new_node1["self"]
      relationships[1]["end"].should == new_node3["self"]
      relationships[1]["type"].should == "enemies"
      relationships[1]["data"]["met"].should == "work"
      relationships[1]["data"]["since"].should == '10-2-2010'
    end

    it "can get a node's outgoing relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node3, new_node1, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships(new_node1, "out")
      relationships.should_not be_nil
      relationships[0]["start"].should == new_node1["self"]
      relationships[0]["end"].should == new_node2["self"]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
      relationships[1].should be_nil
    end

    it "can get a node's incoming relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node3, new_node1, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships(new_node1, "in")
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
      new_relationship = @neo.create_relationship("enemies", new_node1, new_node3, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships(new_node1, "all", "friends")
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
      relationships = @neo.get_node_relationships(new_node1, "in", "enemies")
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
      relationships = @neo.get_node_relationships(new_node1)
      relationships.should be_nil
    end
  end

end