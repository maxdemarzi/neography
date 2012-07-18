require File.join(File.dirname(__FILE__), '..', 'spec_helper')

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
  
end