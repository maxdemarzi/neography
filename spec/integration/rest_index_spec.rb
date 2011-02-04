require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "list indexes" do
    it "can get a listing of indexes" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_to_index("test_index", key, value, new_node) 
      @neo.list_indexes.should_not be_nil
    end
  end

  describe "add to index" do
    it "can add a node to an index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_to_index("test_index", key, value, new_node) 
      new_index = @neo.get_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_from_index("test_index", key, value, new_node) 
    end
  end

  describe "remove from index" do
    it "can remove a node from an index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_to_index("test_index", key, value, new_node) 
      new_index = @neo.get_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_from_index("test_index", key, value, new_node) 
      new_index = @neo.get_index("test_index", key, value) 
      new_index.should be_nil
    end
  end

  describe "get index" do
    it "can get an index" do
      new_node = @neo.create_node
      key = generate_text(6)
      value = generate_text
      @neo.add_to_index("test_index", key, value, new_node) 
      new_index = @neo.get_index("test_index", key, value) 
      new_index.should_not be_nil
      @neo.remove_from_index("test_index", key, value, new_node) 
    end
  end

end