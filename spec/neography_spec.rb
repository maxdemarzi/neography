require 'neography'

describe Neography::Neo do
#  it "has a root node" do
#    Neography::Neo.root_node.should include("reference_node")
#  end
end

describe Neography::Node do
  it "can create an empty node" do
    Neography::Node.new.should include("data"=>{})
  end

  it "can create a node with one property" do
    Neography::Node.new(:name => "Max").should include("data"=>{"name"=>"Max"})
  end

  it "can create a node with more than one property" do
    Neography::Node.new(:age => 31, :name => "Max").should include("data"=>{"age"=>31, "name"=>"Max"})
  end

  it "can find a node by its id" do
    Neography::Node.get_node(2).should include("self"=>"http://localhost:9999/node/2")
  end

  it "fails to find a node that does not exist" do
    Neography::Node.get_node(999).should be_nil
  end

  it "can get a node's properties" do
    Neography::Node.set_properties(3, {:age => 31, :name => "Max"} ).should be_nil
    Neography::Node.properties(3).should include("age"=>31, "name"=>"Max")
  end

  it "returns nil if a node has no properties" do
    Neography::Node.properties(1).should be_nil
  end

  it "can set a node's properties" do
    Neography::Node.set_properties(2, {:age => 32, :name => "Tom"} ).should be_nil
    Neography::Node.properties(2).should include("age"=>32, "name"=>"Tom")
  end

  it "returns nil if it fails to set properties on a node that does not exist" do
    Neography::Node.set_properties(999,{:age => 33, :name => "Harry"}).should be_nil
  end



end