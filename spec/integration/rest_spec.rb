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
      existing_node = Neography::Rest.get_node(1)
      existing_node.should_not be_nil
      existing_node.should have_key("self")
      existing_node["self"].split('/').last.should == "1"
    end

    it "returns nil if it tries to get a node that does not exist" do
      existing_node = Neography::Rest.get_node(9999)
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

    it "returns nil if it fails to set properties on a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.set_node_properties(new_node[:id].to_i + 1, {"weight" => 200, "eyes" => "brown"}).should be_nil
    end
  end

  describe "get_node_properties" do
    it "can get a node's properties" do
      new_node = Neography::Rest.create_node("weight" => 200, "eyes" => "brown")
      new_node[:id] = new_node["self"].split('/').last
      node_properties = Neography::Rest.get_node_properties(new_node[:id])
      node_properties["weight"].should == 200
      node_properties["eyes"].should == "brown"
    end

    it "returns nil if it gets the properties on a node that does not have any" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.get_node_properties(new_node[:id].to_i + 1).should be_nil
    end

    it "returns nil if it fails to get properties on a node that does not exist" do
      new_node = Neography::Rest.create_node
      new_node[:id] = new_node["self"].split('/').last
      Neography::Rest.get_node_properties(new_node[:id].to_i + 1).should be_nil
    end
  end


end