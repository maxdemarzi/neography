require 'spec_helper'

describe Neography::Index do

  it "can add a node to an index" do
    new_node = Neography::Node.create
    key = generate_text(6)
    value = generate_text
    new_node.add_to_index("node_test_index", key, value)
  end

  it "can add a relationship to an index" do
    node1 = Neography::Node.create
    node2 = Neography::Node.create
    r = Neography::Relationship.create(:friends, node1, node2)
    key = generate_text(6)
    value = generate_text
    r.add_to_index("relationship_test_index", key, value)
  end

  it "can find a node in an index" do
    value = generate_text
    new_node = Neography::Node.create("name" => value)
    new_node.add_to_index("node_test_index", "name", value)
    existing_node = Neography::Node.find("node_test_index", "name", value)
    existing_node.name.should == value
  end

  it "can find a relationship in an index" do
    value = generate_text
    node1 = Neography::Node.create
    node2 = Neography::Node.create
    r = Neography::Relationship.create(:friends, node1, node2, {"name" => value})
    r.add_to_index("relationship_test_index", "name", value)
    existing_r = Neography::Relationship.find("relationship_test_index", "name", value)
    existing_r.name.should == value
  end

  it "can find multiple nodes in an index" do
    value1 = generate_text
    value2 = generate_text
    value3 = generate_text
    node1 = Neography::Node.create("first_name" => value1, "last_name" => value2)
    node1.add_to_index("node_test_index", "first_name", value1)
    node2 = Neography::Node.create("first_name" => value1, "last_name" => value3)
    node2.add_to_index("node_test_index", "first_name", value1)

    existing_nodes = Neography::Node.find("node_test_index", "first_name", value1)
    existing_nodes.size.should == 2
    existing_nodes.first.last_name.should == value2
    existing_nodes.last.last_name.should == value3
  end


end
