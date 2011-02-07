require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "list indexes" do
    it "can get a listing of node indexes" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_index", key, value, new_node) 
      @neo.list_indexes.should_not be_nil
    end

    it "can get a listing of relationship indexes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_index", key, value, new_relationship) 
      @neo.list_relationship_indexes.should_not be_nil
    end
  end

  describe "add to index" do
    it "can add a node to an index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_node_from_index("test_index", key, value, new_node) 
    end
  
    it "can add a relationship to an index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_relationship_from_index("test_index", key, value, new_relationship) 
    end
  end

  describe "remove from index" do
    it "can remove a node from an index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_node_from_index("test_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_index", key, value) 
      new_index.should be_nil
    end

    it "can remove a relationshp from an index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_relationship_from_index("test_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_index", key, value) 
      new_index.should be_nil
    end
  end

  describe "get index" do
    it "can get a node index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_node_from_index("test_index", key, value, new_node) 
    end

    it "can get a relationship index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_relationship_from_index("test_index", key, value, new_relationship)
    end
  end

  describe "query index" do
    it "can query a node index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_index", key, value, new_node) 
      new_index = @neo.get_node_index("test_index", key, value) 
      new_index.first["self"].should == new_node["self"]
      @neo.remove_node_from_index("test_index", key, value, new_node) 
    end

    it "can get a relationship index" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      key = generate_text(6)
      value = generate_text
      @neo.add_relationship_to_index("test_index", key, value, new_relationship) 
      new_index = @neo.get_relationship_index("test_index", key, value) 
      new_index.first["self"].should == new_relationship["self"]
      @neo.remove_relationship_from_index("test_index", key, value, new_relationship)
    end
  end


end