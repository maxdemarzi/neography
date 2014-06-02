require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "list indexes" do
    it "can get a listing of node indexes" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      expect(@neo.list_indexes).not_to be_nil
    end

    it "can get a listing of relationship indexes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      expect(@neo.list_relationship_indexes).not_to be_nil
    end
  end

  describe "create an index" do
    it "can create a node index" do
      name = generate_text(6)
      new_index = @neo.create_node_index(name)
      expect(new_index).not_to be_nil
      expect(new_index["template"]).to eq("#{@neo.configuration}/db/data/index/node/#{name}/{key}/{value}")
      expect(new_index["provider"]).to eq("lucene")
      expect(new_index["type"]).to eq("exact")
    end

    it "can create a node index with options" do
      name = generate_text(6)
      new_index = @neo.create_node_index(name, "fulltext","lucene")
      expect(new_index).not_to be_nil
      expect(new_index["template"]).to eq("#{@neo.configuration}/db/data/index/node/#{name}/{key}/{value}")
      expect(new_index["provider"]).to eq("lucene")
      expect(new_index["type"]).to eq("fulltext")
    end

    it "can create a node index with extra configuration options" do
      name = generate_text(6)
      new_index = @neo.create_node_index(name, "fulltext","lucene", extra: 'extra-value')
      expect(new_index).not_to be_nil
      expect(new_index["template"]).to eq("#{@neo.configuration}/db/data/index/node/#{name}/{key}/{value}")
      expect(new_index["provider"]).to eq("lucene")
      expect(new_index["extra"]).to eq("extra-value")
      expect(new_index["type"]).to eq("fulltext")
    end

    it "can create a relationship index" do
      name = generate_text(6)
      new_index = @neo.create_relationship_index(name)
      expect(new_index).not_to be_nil
      expect(new_index["template"]).to eq("#{@neo.configuration}/db/data/index/relationship/#{name}/{key}/{value}")
      expect(new_index["provider"]).to eq("lucene")
      expect(new_index["type"]).to eq("exact")
    end

    it "can create a relationship index with options" do
      name = generate_text(6)
      new_index = @neo.create_relationship_index(name, "fulltext","lucene")
      expect(new_index).not_to be_nil
      expect(new_index["template"]).to eq("#{@neo.configuration}/db/data/index/relationship/#{name}/{key}/{value}")
      expect(new_index["provider"]).to eq("lucene")
      expect(new_index["type"]).to eq("fulltext")
    end


  end

  describe "add to index" do
    it "can add a node to an index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_node_from_index("test_node_index", key, value, new_node) 
    end
  
    it "can add a relationship to an index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_relationship_from_index("test_relationship_index", key, value, new_relationship) 
    end
  end

  describe "remove from index" do
    it "can remove a node from an index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_node_from_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).to be_nil
    end

    it "can remove a node from an index without supplying value" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_node_from_index("test_node_index", key, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).to be_nil
    end

    it "can remove a node from an index without supplying key nor value" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_node_from_index("test_node_index", new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).to be_nil
    end

    it "can remove a relationship from an index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_relationship_from_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).to be_nil
    end

    it "can remove a relationship from an index without supplying value" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_relationship_from_index("test_relationship_index", key, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).to be_nil
    end

    it "can remove a relationship from an index without supplying key nor value" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_relationship_from_index("test_relationship_index", new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).to be_nil
    end

    it "throws an error when there is an empty string in the value when removing a node" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).not_to be_nil
      expect { @neo.remove_node_from_index("test_node_index", key, "", new_node) }.to raise_error Neography::NeographyError
    end
  end

  describe "get index" do
    it "can get a node index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_node_from_index("test_node_index", key, value, new_node) 
    end

    it "can get a node index with a space in the value" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text + " " + generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node)
      new_index = @neo.get_node_index("test_node_index", key, value)
      expect(new_index).not_to be_nil
      @neo.remove_node_from_index("test_node_index", key, value, new_node)
    end

    it "can get a node index with a slash in the value" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text + "/" + generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node)
      new_index = @neo.get_node_index("test_node_index", key, value)
      expect(new_index).not_to be_nil
      @neo.remove_node_from_index("test_node_index", key, value, new_node)
    end

    it "can get a relationship index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.remove_relationship_from_index("test_relationship_index", key, value, new_relationship)
    end
  end

  describe "query index" do
    it "can query a node index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index.first["self"]).to eq(new_node["self"])
      @neo.remove_node_from_index("test_node_index", key, value, new_node) 
    end

    it "can find a node index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.find_node_index("test_node_index", key, value) 
      expect(new_index.first["self"]).to eq(new_node["self"])
      @neo.remove_node_from_index("test_node_index", key, value, new_node) 
    end

    it "can find a node index using generic query" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node)
      new_index = @neo.find_node_index("test_node_index", "#{key}: #{value}")
      expect(new_index.first["self"]).to eq(new_node["self"])
      @neo.remove_node_from_index("test_node_index", key, value, new_node)
    end

    it "can find a node index with spaces in the value" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text + ' ' + generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node)
      new_index = @neo.find_node_index("test_node_index", key, value)
      expect(new_index).not_to be_nil
      expect(new_index.first["self"]).to eq(new_node["self"])
      @neo.remove_node_from_index("test_node_index", key, value, new_node)
    end

    it "can find a node index with slashes in the value" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text + '/' + generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node)
      new_index = @neo.find_node_index("test_node_index", key, value)
      expect(new_index).not_to be_nil
      expect(new_index.first["self"]).to eq(new_node["self"])
      @neo.remove_node_from_index("test_node_index", key, value, new_node)
    end

    it "can get a relationship index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index.first["self"]).to eq(new_relationship["self"])
      @neo.remove_relationship_from_index("test_relationship_index", key, value, new_relationship)
    end

    it "can get a relationship index with empty spaces" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text + " " + generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index.first["self"]).to eq(new_relationship["self"])
      @neo.remove_relationship_from_index("test_relationship_index", key, value, new_relationship)
    end

    it "can find a relationship index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.find_relationship_index("test_relationship_index", key, value) 
      expect(new_index.first["self"]).to eq(new_relationship["self"])
      @neo.remove_relationship_from_index("test_relationship_index", key, value, new_relationship)
    end

    it "can find a relationship index using generic query" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship)
      new_index = @neo.find_relationship_index("test_relationship_index", "#{key}: #{value}")
      expect(new_index.first["self"]).to eq(new_relationship["self"])
      @neo.remove_relationship_from_index("test_relationship_index", key, value, new_relationship)
    end

    it "can find use the results of a node index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      key = generate_text(6)
      value1 = generate_text
      value2 = generate_text
      @neo.add_node_to_index("test_node_index", key, value1, new_node1) 
      @neo.add_node_to_index("test_node_index", key, value2, new_node2) 
      existing_node1 = @neo.get_node_index("test_node_index", key, value1)
      existing_node2 = @neo.get_node_index("test_node_index", key, value2)
      new_relationship = @neo.create_relationship("friends", existing_node1, existing_node2)
      expect(new_relationship["start"]).not_to be_nil
      expect(new_relationship["start"]).to eq(new_node1["self"])
      expect(new_relationship["end"]).not_to be_nil
      expect(new_relationship["end"]).to eq(new_node2["self"])
      @neo.remove_node_from_index("test_node_index", new_node1) 
      @neo.remove_node_from_index("test_node_index", new_node2) 
    end

  end

  describe "auto indexes" do

    it "can check the status of node auto index" do
      expect(@neo.get_node_auto_index_status).to satisfy{|status| [true, false].include?(status)}
    end
  
    it "can check the status of relationship auto index" do
      expect(@neo.get_relationship_auto_index_status).to satisfy{|status| [true, false].include?(status)}
    end

    it "can change the node auto index status" do
      @neo.set_node_auto_index_status(true)
      expect(@neo.get_node_auto_index_status).to be true
    end

    it "can change the relationship auto index status" do
      @neo.set_relationship_auto_index_status(true)
      expect(@neo.get_relationship_auto_index_status).to be true
    end

    it "can get a list of auto indexed node properties" do
      @neo.set_node_auto_index_status(true)
      @neo.create_node_auto_index
      @neo.add_node_auto_index_property("name")
      expect(@neo.get_node_auto_index_properties).to eq(["name"])
    end

    it "can get a list of auto indexed relationship properties" do
      @neo.set_relationship_auto_index_status(true)
      @neo.create_relationship_auto_index
      @neo.add_relationship_auto_index_property("weight")
      expect(@neo.get_relationship_auto_index_properties).to eq(["weight"])
    end

   it "can remove a property from the auto indexed node properties" do
      @neo.add_node_auto_index_property("name")
      @neo.add_node_auto_index_property("label")
      expect(@neo.get_node_auto_index_properties).to eq(["name", "label"])
      @neo.remove_node_auto_index_property("label")   
      expect(@neo.get_node_auto_index_properties).to eq(["name"])
   end

   it "can remove a property from the auto indexed relationship properties" do
      @neo.add_relationship_auto_index_property("weight")
      @neo.add_relationship_auto_index_property("strength")
      expect(@neo.get_relationship_auto_index_properties).to match_array(["weight", "strength"])
      @neo.remove_relationship_auto_index_property("strength")   
      expect(@neo.get_relationship_auto_index_properties).to eq(["weight"])
   end

    it "can get a node from an automatic index" do
      new_node = @neo.create_node("name" => "Max")
      existing_nodes = @neo.get_node_auto_index("name", "Max")
      expect(existing_nodes.collect{|n| n["self"]}.include?(new_node["self"])).to be true 
    end

    it "can query a node from an automatic index using key value" do
      new_node = @neo.create_node("name" => "Max")
      existing_nodes = @neo.find_node_auto_index("name", "Max")
      expect(existing_nodes.collect{|n| n["self"]}.include?(new_node["self"])).to be true 
    end

    it "can query a node from an automatic index" do
      new_node = @neo.create_node("name" => "Max")
      existing_nodes = @neo.find_node_auto_index("name:Max")
      expect(existing_nodes.collect{|n| n["self"]}.include?(new_node["self"])).to be true
      # check that more complex queries are correctly handled
      existing_nodes = @neo.find_node_auto_index("name:Max OR name:Max")
      expect(existing_nodes.collect{|n| n["self"]}.include?(new_node["self"])).to be true
    end

    it "can get a relationship from an automatic index" do
      new_node1 = @neo.create_node("name" => "Max")
      new_node2 = @neo.create_node("name" => "Peter")
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"weight" => 5})
      existing_rels = @neo.get_relationship_auto_index("weight", 5)
      expect(existing_rels.collect{|n| n["self"]}.include?(new_relationship["self"])).to be true 
    end

    it "can query a relationship from an automatic index using key value" do
      new_node1 = @neo.create_node("name" => "Max")
      new_node2 = @neo.create_node("name" => "Peter")
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"weight" => 5})
      existing_rels = @neo.find_relationship_auto_index("weight", 5)
      expect(existing_rels.collect{|n| n["self"]}.include?(new_relationship["self"])).to be true 
    end

    it "can query a relationship from an automatic index" do
      new_node1 = @neo.create_node("name" => "Max")
      new_node2 = @neo.create_node("name" => "Peter")
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"weight" => 5})
      existing_rels = @neo.find_relationship_auto_index("weight:5")
      expect(existing_rels.collect{|n| n["self"]}.include?(new_relationship["self"])).to be true 
    end

  end

  describe "drop index" do
    it "can drop a node index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_node_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.drop_node_index("test_node_index")
      expect { @neo.get_node_index("test_node_index", key, value) }.to raise_error Neography::NotFoundException
    end

    it "can get a relationship index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_relationship_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_relationship_index", key, value) 
      expect(new_index).not_to be_nil
      @neo.drop_relationship_index("test_relationship_index") 
      expect { @neo.get_relationship_index("test_relationship_index", key, value) }.to raise_error Neography::NotFoundException
    end
  end

end
