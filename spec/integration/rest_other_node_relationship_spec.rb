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
      expect(existing_relationships[0]).not_to be_nil
      expect(existing_relationships[0]).to have_key("self")
      expect(existing_relationships[0]["self"]).to eq(new_relationship["self"])
    end

    it "returns empty array if it tries to get a relationship that does not exist" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      existing_relationship = @neo.get_node_relationships_to(new_node1, new_node3)
      expect(existing_relationship).to be_empty
    end
  end

  describe "get_node_relationships" do
    it "can get a node's relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node2)
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
      new_relationship = @neo.create_relationship("enemies", new_node1, new_node2, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node2)
      expect(relationships).not_to be_nil
      expect(relationships[1]["start"]).to eq(new_node1["self"])
      expect(relationships[1]["end"]).to eq(new_node2["self"])
      expect(relationships[1]["type"]).to eq("friends")
      expect(relationships[1]["data"]["met"]).to eq("college")
      expect(relationships[1]["data"]["since"]).to eq('10-1-2005')
      expect(relationships[0]["start"]).to eq(new_node1["self"])
      expect(relationships[0]["end"]).to eq(new_node2["self"])
      expect(relationships[0]["type"]).to eq("enemies")
      expect(relationships[0]["data"]["met"]).to eq("work")
      expect(relationships[0]["data"]["since"]).to eq('10-2-2010')
    end

    it "can get all of a node's outgoing relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node2, new_node1, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node2, "out")
      expect(relationships).not_to be_nil
      expect(relationships[0]["start"]).to eq(new_node1["self"])
      expect(relationships[0]["end"]).to eq(new_node2["self"])
      expect(relationships[0]["type"]).to eq("friends")
      expect(relationships[0]["data"]["met"]).to eq("college")
      expect(relationships[0]["data"]["since"]).to eq('10-1-2005')
      expect(relationships[1]).to be_nil
    end

    it "can get all of a node's incoming relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      new_relationship = @neo.create_relationship("enemies", new_node3, new_node1, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node3, "in")
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
      new_relationship = @neo.create_relationship("friends", new_node1, new_node3, {"since" => '10-2-2010', "met" => "work"})
      relationships = @neo.get_node_relationships_to(new_node1, new_node2, "all", "friends")
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
      relationships = @neo.get_node_relationships_to(new_node1, new_node4, "in", "enemies")
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
      new_node2 = @neo.create_node
      relationships = @neo.get_node_relationships_to(new_node1, new_node2)
      expect(relationships).to be_empty
    end
  end

end
