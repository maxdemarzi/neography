require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "create_relationship" do
    it "can create an empty relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      expect(new_relationship["start"]).not_to be_nil
      expect(new_relationship["end"]).not_to be_nil
    end

    it "can create a relationship with one property" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010'})
      expect(new_relationship["data"]["since"]).to eq('10-1-2010')
    end

    it "can create a relationship with more than one property" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      expect(new_relationship["data"]["since"]).to eq('10-1-2010')
      expect(new_relationship["data"]["met"]).to eq("college")
    end

    it "can create a unique node with more than one property" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_node_index(index_name)
      new_node = @neo.create_unique_node(index_name, key, value, {"age" => 31, "name" => "Max"})
      expect(new_node["data"]["name"]).to eq("Max")
      expect(new_node["data"]["age"]).to eq(31)
    end

    it "can create a unique relationship" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_unique_relationship(index_name, key, value, "friends", new_node1, new_node2)
      expect(new_relationship["data"][key]).to eq(value)
    end

  end

  describe "get_relationship" do
    it "can get a relationship that exists" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      existing_relationship = @neo.get_relationship(new_relationship)
      expect(existing_relationship).not_to be_nil
      expect(existing_relationship).to have_key("self")
      expect(existing_relationship["self"]).to eq(new_relationship["self"])
    end

    it "raises error if it tries to get a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      expect {
        existing_relationship = @neo.get_relationship(fake_relationship)
      }.to raise_error Neography::RelationshipNotFoundException
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
      expect(relationship_properties["since"]).to eq('10-1-2010')
      expect(relationship_properties["met"]).to eq("college")
      expect(relationship_properties["roommates"]).to eq("no")
    end

    it "it fails to set properties on a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      expect {
        @neo.set_relationship_properties(fake_relationship, {"since" => '10-1-2010', "met" => "college"})
      }.to raise_error Neography::RelationshipNotFoundException
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
      expect(relationship_properties["since"]).to be_nil
      expect(relationship_properties["met"]).to be_nil
      expect(relationship_properties["roommates"]).to eq("no")
    end

    it "it fails to reset properties on a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      expect {
        @neo.reset_relationship_properties(fake_relationship, {"since" => '10-1-2010', "met" => "college"})
      }.to raise_error Neography::RelationshipNotFoundException
    end
  end

  describe "get_relationship_properties" do
    it "can get all of a relationship's properties" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      relationship_properties = @neo.get_relationship_properties(new_relationship)
      expect(relationship_properties["since"]).to eq('10-1-2010')
      expect(relationship_properties["met"]).to eq("college")
    end

    it "can get some of a relationship's properties" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college", "roommates" => "no"})
      relationship_properties = @neo.get_relationship_properties(new_relationship, ["since", "roommates"])
      expect(relationship_properties["since"]).to eq('10-1-2010')
      expect(relationship_properties["met"]).to be_nil
      expect(relationship_properties["roommates"]).to eq("no")
    end

    it "returns nil if it gets the properties on a relationship that does not have any" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      relationship_properties = @neo.get_relationship_properties(new_relationship)
      expect(relationship_properties).to be_empty
    end

    it "raises error if it tries to get some of the properties on a relationship that does not have any" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      expect {
        @neo.get_relationship_properties(new_relationship, ["since", "roommates"])
      }.to raise_error Neography::NoSuchPropertyException
    end

    it "raises error if it fails to get properties on a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      expect {
        @neo.get_relationship_properties(fake_relationship)
      }.to raise_error Neography::RelationshipNotFoundException
    end
  end

  describe "remove_relationship_properties" do
    it "can remove a relationship's properties" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      @neo.remove_relationship_properties(new_relationship)
      expect(@neo.get_relationship_properties(new_relationship)).to be_empty
    end

    it "raises error if it fails to remove the properties of a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      expect {
        @neo.remove_relationship_properties(fake_relationship)
      }.to raise_error Neography::RelationshipNotFoundException
    end

    it "can remove a specific relationship property" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      @neo.remove_relationship_properties(new_relationship, "met")
      relationship_properties = @neo.get_relationship_properties(new_relationship)
      expect(relationship_properties["met"]).to be_nil
      expect(relationship_properties["since"]).to eq('10-1-2010')
    end

    it "can remove more than one relationship property" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college", "roommates" => "no"})
      @neo.remove_relationship_properties(new_relationship, ["met", "since"])
      relationship_properties = @neo.get_relationship_properties(new_relationship)
      expect(relationship_properties["met"]).to be_nil
      expect(relationship_properties["since"]).to be_nil
      expect(relationship_properties["roommates"]).to eq("no")
    end
  end

  describe "delete_relationship" do
    it "can delete an existing relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      @neo.delete_relationship(new_relationship)
      relationships = @neo.get_node_relationships(new_node1)
      expect(relationships).to be_empty
    end

    it "raises error if it tries to delete a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      fake_relationship = new_relationship["self"].split('/').last.to_i + 1000
      expect {
        existing_relationship = @neo.delete_relationship(fake_relationship)
      }.to raise_error Neography::RelationshipNotFoundException
    end

    it "returns nil if it tries to delete a relationship that has already been deleted" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2010', "met" => "college"})
      existing_relationship = @neo.delete_relationship(new_relationship)
      expect(existing_relationship).to be_nil
      expect {
        existing_relationship = @neo.delete_relationship(new_relationship)
      }.to raise_error Neography::RelationshipNotFoundException
    end
  end

  describe "get_node_relationships" do
    it "can get a node's relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      relationships = @neo.get_node_relationships(new_node1)
      expect(relationships).not_to be_nil
      expect(relationships[0]["start"]).to eq(new_node1["self"])
      expect(relationships[0]["end"]).to eq(new_node2["self"])
      expect(relationships[0]["type"]).to eq("friends")
      expect(relationships[0]["data"]["met"]).to eq("college")
      expect(relationships[0]["data"]["since"]).to eq('10-1-2005')
    end

    it "can get a node's multiple relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node1, new_node3, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships(new_node1)
      expect(relationships).not_to be_nil
      expect(relationships[1]["start"]).to eq(new_node1["self"])
      expect(relationships[1]["end"]).to eq(new_node2["self"])
      expect(relationships[1]["type"]).to eq("friends")
      expect(relationships[1]["data"]["met"]).to eq("college")
      expect(relationships[1]["data"]["since"]).to eq('10-1-2005')
      expect(relationships[0]["start"]).to eq(new_node1["self"])
      expect(relationships[0]["end"]).to eq(new_node3["self"])
      expect(relationships[0]["type"]).to eq("enemies")
      expect(relationships[0]["data"]["met"]).to eq("work")
      expect(relationships[0]["data"]["since"]).to eq('10-2-2010')
    end

    it "can get a node's outgoing relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node3, new_node1, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships(new_node1, "out")
      expect(relationships).not_to be_nil
      expect(relationships[0]["start"]).to eq(new_node1["self"])
      expect(relationships[0]["end"]).to eq(new_node2["self"])
      expect(relationships[0]["type"]).to eq("friends")
      expect(relationships[0]["data"]["met"]).to eq("college")
      expect(relationships[0]["data"]["since"]).to eq('10-1-2005')
      expect(relationships[1]).to be_nil
    end

    it "can get a node's incoming relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node3, new_node1, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships(new_node1, "in")
      expect(relationships).not_to be_nil
      expect(relationships[0]["start"]).to eq(new_node3["self"])
      expect(relationships[0]["end"]).to eq(new_node1["self"])
      expect(relationships[0]["type"]).to eq("enemies")
      expect(relationships[0]["data"]["met"]).to eq("work")
      expect(relationships[0]["data"]["since"]).to eq('10-2-2010')
      expect(relationships[1]).to be_nil
    end

    it "can get a specific type of node relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node1, new_node3, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships(new_node1, "all", "friends")
      expect(relationships).not_to be_nil
      expect(relationships[0]["start"]).to eq(new_node1["self"])
      expect(relationships[0]["end"]).to eq(new_node2["self"])
      expect(relationships[0]["type"]).to eq("friends")
      expect(relationships[0]["data"]["met"]).to eq("college")
      expect(relationships[0]["data"]["since"]).to eq('10-1-2005')
      expect(relationships[1]).to be_nil
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
      expect(relationships).not_to be_nil
      expect(relationships[0]["start"]).to eq(new_node4["self"])
      expect(relationships[0]["end"]).to eq(new_node1["self"])
      expect(relationships[0]["type"]).to eq("enemies")
      expect(relationships[0]["data"]["met"]).to eq("gym")
      expect(relationships[0]["data"]["since"]).to eq('10-3-2010')
      expect(relationships[1]).to be_nil
    end

    it "returns nil if there are no relationships" do
      new_node1 = @neo.create_node
      relationships = @neo.get_node_relationships(new_node1)
      expect(relationships).to be_empty
    end
  end

end
