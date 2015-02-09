require 'spec_helper'

describe Neography::Index do

  it "can add a node to an index" do
    new_node = Neography::Node.create
    key = generate_text(6)
    value = generate_text
    new_node.add_to_index("node_test_index", key, value)
  end

  it "can add a node to an index uniquely" do
    new_node = Neography::Node.create
    key = generate_text(6)
    value = generate_text
    new_node.add_to_index("node_test_index", key, value, true)
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
    expect(existing_node.name).to eq(value)
  end

  it "can find a node in an index with brackets" do
    key = generate_text(6)
    value = "Sen. Roy Blunt [R-MO]"
    new_node = Neography::Node.create("name" => value)
    new_node.add_to_index(key, "name", value)
    existing_node = Neography::Node.find(key, "name", value)
    expect(existing_node.name).to eq(value)
  end

  it "can find a relationship in an index" do
    value = generate_text
    node1 = Neography::Node.create
    node2 = Neography::Node.create
    r = Neography::Relationship.create(:friends, node1, node2, {"name" => value})
    r.add_to_index("relationship_test_index", "name", value)
    existing_r = Neography::Relationship.find("relationship_test_index", "name", value)
    expect(existing_r.name).to eq(value)
    expect(existing_r.start_node).to eq(node1)
    expect(existing_r.end_node).to eq(node2)
    existing_r.del
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
    expect(existing_nodes.size).to eq(2)
    expect(existing_nodes.first.last_name).to eq(value2)
    expect(existing_nodes.last.last_name).to eq(value3)
  end


end
