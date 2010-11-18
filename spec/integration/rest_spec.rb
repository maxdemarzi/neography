require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do

  describe "get_root" do
    it "can get the root node" do
      root_node = Neography::Rest.get_root
      root_node.should have_key("reference_node")
    end
  end

  describe "create_node" do
    it "can create an empty node" do
      new_node = Neography::Rest.create_node
      new_node.should_not be_nil
    end

    it "can create a node with one property" do
      new_node = Neography::Rest.create_node("name" => "Max")
      new_node["data"]["name"].should == "Max"
    end

    it "can create a node with more than one property" do
      new_node = Neography::Rest.create_node("age" => 31, "name" => "Max")
      new_node["data"]["name"].should == "Max"
      new_node["data"]["age"].should == 31
    end
  end

  describe "get_node" do
    it "can get a node that exists" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node.should_not be_nil
      existing_node.should have_key("self")
      existing_node["self"].split('/').last.should == new_node[:id]
    end

    it "returns nil if it tries to get a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      existing_node = Neography::Rest.get_node(new_node[:id].to_i + 1000)
      existing_node.should be_nil
    end
  end

  describe "set_node_properties" do
    it "can set a node's properties" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.set_node_properties(new_node[:id], {"weight" => 200, "eyes" => "brown"})
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node["data"]["weight"].should == 200
      existing_node["data"]["eyes"].should == "brown"
    end

    it "it fails to set properties on a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.set_node_properties(new_node[:id].to_i + 1000, {"weight" => 150, "hair" => "blonde"})
      node_properties = Neography::Rest.get_node_properties(new_node[:id].to_i + 1000)
      node_properties.should be_nil
    end
  end

  describe "reset_node_properties" do
    it "can reset a node's properties" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.set_node_properties(new_node[:id], {"weight" => 200, "eyes" => "brown", "hair" => "black"})
      Neography::Rest.reset_node_properties(new_node[:id], {"weight" => 190, "eyes" => "blue"})
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node["data"]["weight"].should == 190
      existing_node["data"]["eyes"].should == "blue"
      existing_node["data"]["hair"].should be_nil
    end

    it "it fails to reset properties on a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.reset_node_properties(new_node[:id].to_i + 1000, {"weight" => 170, "eyes" => "green"})
      node_properties = Neography::Rest.get_node_properties(new_node[:id].to_i + 1000)
      node_properties.should be_nil
    end
  end

  describe "get_node_properties" do
    it "can get all of a node's properties" do
      new_node = Neography::Rest.create_node("weight" => 200, "eyes" => "brown")
      new_node[:id] = new_node["self"].split('/').last
      node_properties = Neography::Rest.get_node_properties(new_node[:id])
      node_properties["weight"].should == 200
      node_properties["eyes"].should == "brown"
    end

    it "can get some of a node's properties" do
      new_node = Neography::Rest.create_node("weight" => 200, "eyes" => "brown", "height" => "2m")
      new_node[:id] = new_node["self"].split('/').last
      node_properties = Neography::Rest.get_node_properties(new_node[:id], ["weight", "height"])
      node_properties["weight"].should == 200
      node_properties["height"].should == "2m"
      node_properties["eyes"].should be_nil
    end

    it "returns nil if it gets the properties on a node that does not have any" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.get_node_properties(new_node[:id]).should be_nil
    end

    it "returns nil if it tries to get some of the properties on a node that does not have any" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.get_node_properties(new_node[:id], ["weight", "height"]).should be_nil
    end

    it "returns nil if it fails to get properties on a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.get_node_properties(new_node[:id].to_i + 10000).should be_nil
    end
  end

  describe "remove_node_properties" do
    it "can remove a node's properties" do
      new_node = Neography::Rest.create_node("weight" => 200, "eyes" => "brown")
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.remove_node_properties(new_node[:id])
      Neography::Rest.get_node_properties(new_node[:id]).should be_nil
    end

    it "returns nil if it fails to remove the properties of a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.remove_node_properties(new_node[:id].to_i + 10000).should be_nil
    end

    it "can remove a specific node property" do
      new_node = Neography::Rest.create_node("weight" => 200, "eyes" => "brown")
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.remove_node_properties(new_node[:id], "weight")
      node_properties = Neography::Rest.get_node_properties(new_node[:id])
      node_properties["weight"].should be_nil
      node_properties["eyes"].should == "brown"
    end

    it "can remove more than one property" do
      new_node = Neography::Rest.create_node("weight" => 200, "eyes" => "brown", "height" => "2m")
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.remove_node_properties(new_node[:id], ["weight", "eyes"])
      node_properties = Neography::Rest.get_node_properties(new_node[:id])
      node_properties["weight"].should be_nil
      node_properties["eyes"].should be_nil
    end
  end

  describe "delete_node" do
    it "can delete an unrelated node" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.delete_node(new_node[:id]).should be_nil
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node.should be_nil
    end

    it "cannot delete a node that has relationships" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      Neography::Rest.delete_node(new_node1[:id]).should be_nil
      existing_node = Neography::Rest.get_node(new_node1[:id])
      existing_node.should_not be_nil
    end

    it "returns nil if it tries to delete a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.delete_node(new_node[:id].to_i + 1000).should be_nil
      existing_node = Neography::Rest.get_node(new_node[:id].to_i + 1000)
      existing_node.should be_nil
    end

    it "returns nil if it tries to delete a node that has already been deleted" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.delete_node(new_node[:id]).should be_nil
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node.should be_nil
      Neography::Rest.delete_node(new_node[:id]).should be_nil
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node.should be_nil
    end
  end

  describe "delete_node!" do
    it "can delete an unrelated node" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.delete_node!(new_node[:id]).should be_nil
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node.should be_nil
    end

    it "can delete a node that has relationships" do
      new_node1 = Neography::Rest.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = Neography::Rest.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      Neography::Rest.create_relationship("friends", new_node1[:id], new_node2[:id])
      Neography::Rest.delete_node!(new_node1[:id]).should be_nil
      existing_node = Neography::Rest.get_node(new_node1[:id])
      existing_node.should be_nil
    end

    it "returns nil if it tries to delete a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.delete_node!(new_node[:id].to_i + 1000).should be_nil
      existing_node = Neography::Rest.get_node(new_node[:id].to_i + 1000)
      existing_node.should be_nil
    end

    it "returns nil if it tries to delete a node that has already been deleted" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.delete_node!(new_node[:id]).should be_nil
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node.should be_nil
      Neography::Rest.delete_node!(new_node[:id]).should be_nil
      existing_node = Neography::Rest.get_node(new_node[:id])
      existing_node.should be_nil
    end
  end

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
      relationships = Neography::Rest.get_node_relationships(new_node1[:id], "outgoing")
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
      relationships = Neography::Rest.get_node_relationships(new_node1[:id], "incoming")
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
      relationships = Neography::Rest.get_node_relationships(new_node1[:id], "incoming", "enemies")
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