require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "simple batch" do
    it "can get a single node" do
      new_node = @neo.create_node
      new_node[:id] = new_node["self"].split('/').last
      batch_result = @neo.batch [:get_node, new_node]
      batch_result.first.should_not be_nil
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("body")
      batch_result.first.should have_key("from")
      batch_result.first["body"]["self"].split('/').last.should == new_node[:id]
    end
    
    it "can get multiple nodes" do
      node1 = @neo.create_node
      node1[:id] = node1["self"].split('/').last
      node2 = @neo.create_node
      node2[:id] = node2["self"].split('/').last

      batch_result = @neo.batch [:get_node, node1], [:get_node, node2]
      batch_result.first.should_not be_nil
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("body")
      batch_result.first.should have_key("from")
      batch_result.first["body"]["self"].split('/').last.should == node1[:id]
      batch_result.last.should have_key("id")
      batch_result.last.should have_key("body")
      batch_result.last.should have_key("from")
      batch_result.last["body"]["self"].split('/').last.should == node2[:id]

    end

    it "can create a single node" do
      batch_result = @neo.batch [:create_node, {"name" => "Max"}]
      batch_result.first["body"]["data"]["name"].should == "Max"
    end

    it "can create multiple nodes" do
      batch_result = @neo.batch [:create_node, {"name" => "Max"}], [:create_node, {"name" => "Marc"}]
      batch_result.first["body"]["data"]["name"].should == "Max"
      batch_result.last["body"]["data"]["name"].should == "Marc"
    end

    it "can update a property of a node" do
      new_node = @neo.create_node("name" => "Max")
      batch_result = @neo.batch [:set_node_property, new_node, {"name" => "Marc"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_node = @neo.get_node(new_node)
      existing_node["data"]["name"].should == "Marc"
    end

    it "can update a property of multiple nodes" do
      node1 = @neo.create_node("name" => "Max")
      node2 = @neo.create_node("name" => "Marc")
      batch_result = @neo.batch [:set_node_property, node1, {"name" => "Tom"}], [:set_node_property, node2, {"name" => "Jerry"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.last.should have_key("id")
      batch_result.last.should have_key("from")
      existing_node = @neo.get_node(node1)
      existing_node["data"]["name"].should == "Tom"
      existing_node = @neo.get_node(node2)
      existing_node["data"]["name"].should == "Jerry"
    end

    it "can reset the properties of a node" do
      new_node = @neo.create_node("name" => "Max", "weight" => 200)
      batch_result = @neo.batch [:reset_node_properties, new_node, {"name" => "Marc"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      existing_node = @neo.get_node(new_node)
      existing_node["data"]["name"].should == "Marc"
      existing_node["data"]["weight"].should be_nil
    end

    it "can reset the properties of multiple nodes" do
      node1 = @neo.create_node("name" => "Max", "weight" => 200)
      node2 = @neo.create_node("name" => "Marc", "weight" => 180)
      batch_result = @neo.batch [:reset_node_properties, node1, {"name" => "Tom"}], [:reset_node_properties, node2, {"name" => "Jerry"}]
      batch_result.first.should have_key("id")
      batch_result.first.should have_key("from")
      batch_result.last.should have_key("id")
      batch_result.last.should have_key("from")
      existing_node = @neo.get_node(node1)
      existing_node["data"]["name"].should == "Tom"
      existing_node["data"]["weight"].should be_nil
      existing_node = @neo.get_node(node2)
      existing_node["data"]["name"].should == "Jerry"
      existing_node["data"]["weight"].should be_nil
    end

    it "can get a single relationship" do
      pending
    end
    
    it "can get multiple relationships" do
      pending
    end

    it "can create a single relationship" do
      pending
    end

    it "can create multiple relationships" do
      pending
    end

    it "can update a single relationship" do
      pending
    end

    it "can update multiple relationships" do
      pending
    end

    it "can add a node to an index" do
      pending
    end
  end

  describe "referenced batch" do
    it "can create a relationship from two newly created nodes" do
      pending
    end

    it "can create a relationship from an existing node and a newly created node" do
      pending
    end

    it "can add a newly created node to an index" do
      pending
    end

    it "can add a newly created relationship to an index" do
      pending
    end
  end
  
end