require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do

  describe "create_relationship" do
    it "can create an empty relationship" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship["start"].should_not be_nil
      new_relationship["end"].should_not be_nil
    end

    it "can create a relationship with one property" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010'})
      new_relationship["data"]["since"].should == '10-1-2010'
    end

    it "can create a relationship with more than one property" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college"})
      new_relationship["data"]["since"].should == '10-1-2010'
      new_relationship["data"]["met"].should == "college"
    end
  end

  describe "set_relationship_properties" do
    it "can set a relationship's properties" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.set_relationship_properties(new_relationship[:id], {"since" => '10-1-2010', "met" => "college"})
      Neography::Rest.set_relationship_properties(new_relationship[:id], {"roommates" => "no"})
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id])
      relationship_properties["since"].should == '10-1-2010'
      relationship_properties["met"].should == "college"
      relationship_properties["roommates"].should == "no"
    end

    it "it fails to set properties on a relationship that does not exist" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.set_relationship_properties(new_relationship[:id].to_i + 10000, {"since" => '10-1-2010', "met" => "college"})
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id].to_i + 10000)
      relationship_properties.should be_nil
    end
  end

  describe "reset_relationship_properties" do
    it "can reset a relationship's properties" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.set_relationship_properties(new_relationship[:id], {"since" => '10-1-2010', "met" => "college"})
      Neography::Rest.reset_relationship_properties(new_relationship[:id], {"roommates" => "no"})
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id])
      relationship_properties["since"].should be_nil
      relationship_properties["met"].should be_nil
      relationship_properties["roommates"].should == "no"
    end

    it "it fails to reset properties on a relationship that does not exist" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.reset_relationship_properties(new_relationship[:id].to_i + 10000, {"since" => '10-1-2010', "met" => "college"})
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id].to_i + 10000)
      relationship_properties.should be_nil
    end
  end

  describe "get_relationship_properties" do
    it "can get all of a relationship's properties" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id])
      relationship_properties["since"].should == '10-1-2010'
      relationship_properties["met"].should == "college"
    end

    it "can get some of a relationship's properties" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college", "roommates" => "no"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id], ["since", "roommates"])
      relationship_properties["since"].should == '10-1-2010'
      relationship_properties["met"].should be_nil
      relationship_properties["roommates"].should == "no"
    end

    it "returns nil if it gets the properties on a relationship that does not have any" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship[:id] = new_relationship["self"].split('/').last
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id])
      relationship_properties.should be_nil
    end

    it "returns nil if it tries to get some of the properties on a relationship that does not have any" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship[:id] = new_relationship["self"].split('/').last
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id], ["since", "roommates"])
      relationship_properties.should be_nil
    end

    it "returns nil if it fails to get properties on a relationship that does not exist" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship[:id] = new_relationship["self"].split('/').last
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id].to_i + 10000)
      relationship_properties.should be_nil
    end
  end

  describe "remove_relationship_properties" do
    it "can remove a relationship's properties" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.remove_relationship_properties(new_relationship[:id])
      Neography::Rest.get_relationship_properties(new_relationship[:id]).should be_nil
    end

    it "returns nil if it fails to remove the properties of a relationship that does not exist" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.remove_relationship_properties(new_relationship[:id])
      Neography::Rest.get_relationship_properties(new_relationship[:id].to_i + 10000).should be_nil
    end

    it "can remove a specific relationship property" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.remove_relationship_properties(new_relationship[:id], "met")
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id], ["met", "since"])
      relationship_properties["met"].should be_nil
      relationship_properties["since"].should == '10-1-2010'
    end

    it "can remove more than one relationship property" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college", "roommates" => "no"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.remove_relationship_properties(new_relationship[:id], ["met", "since"])
      relationship_properties = Neography::Rest.get_relationship_properties(new_relationship[:id], ["since", "met", "roommates"])
      relationship_properties["met"].should be_nil
      relationship_properties["since"].should be_nil
      relationship_properties["roommates"].should == "no"
    end
  end

  describe "delete_relationship" do
    it "can delete an existing relationship" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      Neography::Rest.delete_relationship(new_relationship[:id])
      relationships = Neography::Rest.get_node_relationships(new_node1[:id])
      relationships.should be_nil
    end

    it "returns nil if it tries to delete a relationship that does not exist" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      existing_relationship = Neography::Rest.delete_relationship(new_relationship[:id].to_i + 1000)
      existing_relationship.should be_nil
    end

    it "returns nil if it tries to delete a relationship that has already been deleted" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2010', "met" => "college"})
      new_relationship[:id] = new_relationship["self"].split('/').last
      existing_relationship = Neography::Rest.delete_relationship(new_relationship[:id])
      existing_relationship.should be_nil
      existing_relationship = Neography::Rest.delete_relationship(new_relationship[:id])
      existing_relationship.should be_nil
    end
  end

  describe "get_node_relationships" do
    it "can get a node's relationship" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2005', "met" => "college"})
      relationships = Neography::Rest.get_node_relationships(new_node1[:id])
      relationships.should_not be_nil
      relationships[0]["start"].split('/').last.should == new_node1[:id]
      relationships[0]["end"].split('/').last.should == new_node2[:id]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
    end

    it "can get a node's multiple relationships" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = Neography::Rest.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2005', "met" => "college"})
      new_relationship = Neography::Rest.create_relationship("enemies", new_node1[:id], new_node3[:id], {"since" => '10-2-2010', "met" => "work"})
      relationships = Neography::Rest.get_node_relationships(new_node1[:id])
      relationships.should_not be_nil
      relationships[0]["start"].split('/').last.should == new_node1[:id]
      relationships[0]["end"].split('/').last.should == new_node2[:id]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
      relationships[1]["start"].split('/').last.should == new_node1[:id]
      relationships[1]["end"].split('/').last.should == new_node3[:id]
      relationships[1]["type"].should == "enemies"
      relationships[1]["data"]["met"].should == "work"
      relationships[1]["data"]["since"].should == '10-2-2010'
    end

    it "can get a node's outgoing relationship" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = Neography::Rest.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2005', "met" => "college"})
      new_relationship = Neography::Rest.create_relationship("enemies", new_node3[:id], new_node1[:id], {"since" => '10-2-2010', "met" => "work"})
      relationships = Neography::Rest.get_node_relationships(new_node1[:id], "out")
      relationships.should_not be_nil
      relationships[0]["start"].split('/').last.should == new_node1[:id]
      relationships[0]["end"].split('/').last.should == new_node2[:id]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
      relationships[1].should be_nil
    end

    it "can get a node's incoming relationship" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = Neography::Rest.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2005', "met" => "college"})
      new_relationship = Neography::Rest.create_relationship("enemies", new_node3[:id], new_node1[:id], {"since" => '10-2-2010', "met" => "work"})
      relationships = Neography::Rest.get_node_relationships(new_node1[:id], "in")
      relationships.should_not be_nil
      relationships[0]["start"].split('/').last.should == new_node3[:id]
      relationships[0]["end"].split('/').last.should == new_node1[:id]
      relationships[0]["type"].should == "enemies"
      relationships[0]["data"]["met"].should == "work"
      relationships[0]["data"]["since"].should == '10-2-2010'
      relationships[1].should be_nil
    end

    it "can get a specific type of node relationships" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = Neography::Rest.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2005', "met" => "college"})
      new_relationship = Neography::Rest.create_relationship("enemies", new_node1[:id], new_node3[:id], {"since" => '10-2-2010', "met" => "work"})
      relationships = Neography::Rest.get_node_relationships(new_node1[:id], "all", "friends")
      relationships.should_not be_nil
      relationships[0]["start"].split('/').last.should == new_node1[:id]
      relationships[0]["end"].split('/').last.should == new_node2[:id]
      relationships[0]["type"].should == "friends"
      relationships[0]["data"]["met"].should == "college"
      relationships[0]["data"]["since"].should == '10-1-2005'
      relationships[1].should be_nil
    end

    it "can get a specific type and direction of a node relationships" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = Neography::Rest.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = Neography::Rest.create_node
      new_node4[:id] = new_node4["self"].split('/').last
      new_relationship = Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id], {"since" => '10-1-2005', "met" => "college"})
      new_relationship = Neography::Rest.create_relationship("enemies", new_node1[:id], new_node3[:id], {"since" => '10-2-2010', "met" => "work"})
      new_relationship = Neography::Rest.create_relationship("enemies", new_node4[:id], new_node1[:id], {"since" => '10-3-2010', "met" => "gym"})
      relationships = Neography::Rest.get_node_relationships(new_node1[:id], "in", "enemies")
      relationships.should_not be_nil
      relationships[0]["start"].split('/').last.should == new_node4[:id]
      relationships[0]["end"].split('/').last.should == new_node1[:id]
      relationships[0]["type"].should == "enemies"
      relationships[0]["data"]["met"].should == "gym"
      relationships[0]["data"]["since"].should == '10-3-2010'
      relationships[1].should be_nil
    end

    it "returns nil if there are no relationships" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      relationships = Neography::Rest.get_node_relationships(new_node1[:id])
      relationships.should be_nil
    end
  end

end