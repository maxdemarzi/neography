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

end