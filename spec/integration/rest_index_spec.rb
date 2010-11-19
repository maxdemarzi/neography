require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do

  describe "list indexes" do
    it "can get a listing of indexes" do
      Neography::Rest.list_indexes.should_not be_nil
    end
  end

  describe "add to index" do
    it "can add a node to an index" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      key = generate_text(6)
      value = generate_text
      Neography::Rest.add_to_index(key, value, new_node[:id]) 
      new_index = Neography::Rest.get_index(key, value) 
      new_index.should_not be_nil
      Neography::Rest.remove_from_index(key, value, new_node[:id]) 
    end
  end

  describe "remove from index" do
    it "can remove a node from an index" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      key = generate_text(6)
      value = generate_text
      Neography::Rest.add_to_index(key, value, new_node[:id]) 
      new_index = Neography::Rest.get_index(key, value) 
      new_index.should_not be_nil
      Neography::Rest.remove_from_index(key, value, new_node[:id]) 
      new_index = Neography::Rest.get_index(key, value) 
      new_index.should be_nil
    end
  end

  describe "get index" do
    it "can get an index" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      key = generate_text(6)
      value = generate_text
      Neography::Rest.add_to_index(key, value, new_node[:id]) 
      new_index = Neography::Rest.get_index(key, value) 
      new_index.should_not be_nil
      Neography::Rest.remove_from_index(key, value, new_node[:id]) 
    end
  end

end