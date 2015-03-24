# Encoding: utf-8

require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "get_root" do
    it "can get the root node", :reference => true do
      root_node = @neo.get_root
      expect(root_node).to have_key("self")
      expect(root_node["self"].split('/').last).to eq("0")
    end
  end

  describe "create_node" do
    it "can create an empty node" do
      new_node = @neo.create_node
      expect(new_node).not_to be_nil
    end

    it "can create a node with one property" do
      new_node = @neo.create_node("name" => "Max")
      expect(new_node["data"]["name"]).to eq("Max")
    end

    it "can create a node with nil properties" do
      new_node = @neo.create_node("name" => "Max", "age" => nil )
      expect(new_node["data"]["name"]).to eq("Max")
      expect(new_node["data"]["age"]).to be_nil
    end


    it "can create a node with more than one property" do
      new_node = @neo.create_node("age" => 31, "name" => "Max")
      expect(new_node["data"]["name"]).to eq("Max")
      expect(new_node["data"]["age"]).to eq(31)
    end

    it "can create a unique node with more than one property" do
      index_name = generate_text(6)
      key = generate_text(6)
      value = generate_text
      @neo.create_node_index(index_name)
      new_node = @neo.create_unique_node(index_name, key, value, {"age" => 31, "name" => "Max"})
      expect(new_node["data"]["name"]).to eq("Max")
      expect(new_node["data"]["age"]).to eq(31)
      new_node_id = new_node["self"].split('/').last
      existing_node = @neo.create_unique_node(index_name, key, value, {"age" => 39, "name" => "Thomas"})
      expect(existing_node["self"].split('/').last).to eq(new_node_id)
      expect(existing_node["data"]["name"]).to eq("Max")
      expect(existing_node["data"]["age"]).to eq(31)
    end

  end

  describe "get_node" do
    it "can get a node that exists" do
      new_node = @neo.create_node
      new_node[:id] = new_node["self"].split('/').last
      existing_node = @neo.get_node(new_node)
      expect(existing_node).not_to be_nil
      expect(existing_node).to have_key("self")
      expect(existing_node["self"].split('/').last).to eq(new_node[:id])
    end

    it "raises an error if it tries to get a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      expect {
        @neo.get_node(fake_node)
      }.to raise_error Neography::NodeNotFoundException
    end
    
    it "can get a node with a tilde" do
      new_node = @neo.create_node("name" => "Ateísmo Sureño")
      new_node[:id] = new_node["self"].split('/').last
      existing_node = @neo.get_node(new_node)
      expect(existing_node).not_to be_nil
      expect(existing_node).to have_key("self")
      expect(existing_node["self"].split('/').last).to eq(new_node[:id])
      expect(existing_node["data"]["name"]).to eq("Ateísmo Sureño")
    end
  end

  describe "set_node_properties" do
    it "can set a node's properties" do
      new_node = @neo.create_node
      @neo.set_node_properties(new_node, {"weight" => 200, "eyes" => "brown"})
      existing_node = @neo.get_node(new_node)
      expect(existing_node["data"]["weight"]).to eq(200)
      expect(existing_node["data"]["eyes"]).to eq("brown")
    end

    it "it fails to set properties on a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      expect {
        @neo.set_node_properties(fake_node, {"weight" => 150, "hair" => "blonde"})
      }.to raise_error Neography::NodeNotFoundException
    end
  end

  describe "reset_node_properties" do
    it "can reset a node's properties" do
      new_node = @neo.create_node
      @neo.set_node_properties(new_node, {"weight" => 200, "eyes" => "brown", "hair" => "black"})
      @neo.reset_node_properties(new_node, {"weight" => 190, "eyes" => "blue"})
      existing_node = @neo.get_node(new_node)
      expect(existing_node["data"]["weight"]).to eq(190)
      expect(existing_node["data"]["eyes"]).to eq("blue")
      expect(existing_node["data"]["hair"]).to be_nil
    end

    it "it fails to reset properties on a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      expect {
        @neo.reset_node_properties(fake_node, {"weight" => 170, "eyes" => "green"})
      }.to raise_error Neography::NodeNotFoundException
    end
  end

  describe "get_node_properties" do
    it "can get all of a node's properties" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown")
      node_properties = @neo.get_node_properties(new_node)
      expect(node_properties["weight"]).to eq(200)
      expect(node_properties["eyes"]).to eq("brown")
    end

    it "can get some of a node's properties" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown", "height" => "2m")
      node_properties = @neo.get_node_properties(new_node, ["weight", "height"])
      expect(node_properties["weight"]).to eq(200)
      expect(node_properties["height"]).to eq("2m")
      expect(node_properties["eyes"]).to be_nil
    end

    it "returns empty array if it gets the properties on a node that does not have any" do
      new_node = @neo.create_node
      expect(@neo.get_node_properties(new_node)).to be_empty
    end

    it "raises error if it tries to get some of the properties on a node that does not have any" do
      new_node = @neo.create_node
      expect {
        expect(@neo.get_node_properties(new_node, ["weight", "height"])).to be_nil
      }.to raise_error Neography::NoSuchPropertyException
    end

    it "raises error if it fails to get properties on a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      expect {
        expect(@neo.get_node_properties(fake_node)).to be_nil
      }.to raise_error Neography::NodeNotFoundException
    end
  end

  describe "remove_node_properties" do
    it "can remove a node's properties" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown")
      @neo.remove_node_properties(new_node)
      expect(@neo.get_node_properties(new_node)).to be_empty
    end

    it "raises error if it fails to remove the properties of a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      expect {
        expect(@neo.remove_node_properties(fake_node)).to be_nil
      }.to raise_error Neography::NodeNotFoundException
    end

    it "can remove a specific node property" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown")
      @neo.remove_node_properties(new_node, "weight")
      node_properties = @neo.get_node_properties(new_node)
      expect(node_properties["weight"]).to be_nil
      expect(node_properties["eyes"]).to eq("brown")
    end

    it "can remove more than one property" do
      new_node = @neo.create_node("weight" => 200, "eyes" => "brown", "height" => "2m")
      @neo.remove_node_properties(new_node, ["weight", "eyes"])
      node_properties = @neo.get_node_properties(new_node)
      expect(node_properties["weight"]).to be_nil
      expect(node_properties["eyes"]).to be_nil
    end
  end

  describe "delete_node" do
    it "can delete an unrelated node" do
      new_node = @neo.create_node
      expect(@neo.delete_node(new_node)).to be_nil
      expect {
        @neo.get_node(new_node)
      }.to raise_error Neography::NodeNotFoundException
    end

    it "cannot delete a node that has relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      expect {
        expect(@neo.delete_node(new_node1)).to be_nil
      }.to raise_error Neography::OperationFailureException
      existing_node = @neo.get_node(new_node1)
      expect(existing_node).not_to be_nil
    end

    it "raises error if it tries to delete a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      expect {
        expect(@neo.delete_node(fake_node)).to be_nil
      }.to raise_error Neography::NodeNotFoundException
    end

    it "raises error if it tries to delete a node that has already been deleted" do
      new_node = @neo.create_node
      expect(@neo.delete_node(new_node)).to be_nil
      expect {
        existing_node = @neo.get_node(new_node)
      }.to raise_error Neography::NodeNotFoundException
      expect {
        expect(@neo.delete_node(new_node)).to be_nil
      }.to raise_error Neography::NodeNotFoundException
    end
  end

  describe "delete_node!" do
    it "can delete an unrelated node" do
      new_node = @neo.create_node
      expect(@neo.delete_node!(new_node)).to be_nil
      expect {
        existing_node = @neo.get_node(new_node)
      }.to raise_error Neography::NodeNotFoundException
    end

    it "can delete a node that has relationships" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      expect(@neo.delete_node!(new_node1)).to be_nil
      expect {
        existing_node = @neo.get_node(new_node1)
      }.to raise_error Neography::NodeNotFoundException
    end

    it "raises error if it tries to delete a node that does not exist" do
      new_node = @neo.create_node
      fake_node = new_node["self"].split('/').last.to_i + 1000
      expect {
        expect(@neo.delete_node!(fake_node)).to be_nil
      }.to raise_error Neography::NodeNotFoundException
    end

    it "raises error if it tries to delete a node that has already been deleted" do
      new_node = @neo.create_node
      expect(@neo.delete_node!(new_node)).to be_nil
      expect {
        existing_node = @neo.get_node(new_node)
      }.to raise_error Neography::NodeNotFoundException
      expect {
        expect(@neo.delete_node!(new_node)).to be_nil
      }.to raise_error Neography::NodeNotFoundException
    end
  end

end
