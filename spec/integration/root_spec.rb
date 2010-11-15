require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Neo do
  it "has a root node" do
    Neography::Neo.root_node.should include("reference_node")
  end
end