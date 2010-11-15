require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Node do
  it "can create an empty node" do
    Neography::Node.new.should include(:neo_id)
  end

  it "can create a node with one property" do
    Neography::Node.new(:name => "Max").should include("name"=>"Max")
  end

  it "can create a node with more than one property" do
    Neography::Node.new(:age => 31, :name => "Max").should include("age"=>31, "name"=>"Max")
  end

  it "can find a node by its id" do
    Neography::Node.load(2).should include(:neo_id=>"2")
  end

  it "fails to find a node that does not exist" do
    Neography::Node.load(999).should be_nil
  end

  it "can get a node's properties" do
    Neography::Node.set_properties(3, {:age => 31, :name => "Max"} ).should be_nil
    Neography::Node.properties(3).should include("age"=>31, "name"=>"Max")
  end

  it "returns nil if a node has no properties" do
    Neography::Node.properties(1).should be_nil
  end


  it "returns nil if the properties of a node that does not exist are requested" do
    Neography::Node.properties(999).should be_nil
  end

  it "can set a node's properties" do
    Neography::Node.set_properties(2, {:age => 32, :name => "Tom"} ).should be_nil
    Neography::Node.properties(2).should include("age"=>32, "name"=>"Tom")
  end

  it "returns nil if it fails to set properties on a node that does not exist" do
    Neography::Node.set_properties(999,{:age => 33, :name => "Harry"}).should be_nil
  end

  it "can delete a node's property" do
    Neography::Node.set_properties(2, {:age => 32, :name => "Tom", :weight => 200} ).should be_nil
    Neography::Node.remove_property(2, :weight).should be_nil
    Neography::Node.properties(2).should_not include("weight"=>200)
  end

  it "returns nil if it tries to delete a property that does not exist" do
    Neography::Node.set_properties(2, {:age => 32, :name => "Tom", :weight => 200} ).should be_nil
    Neography::Node.remove_property(2, :height).should be_nil
  end

  it "returns nil if it tries to delete a property on a node that does not exist" do
    Neography::Node.remove_property(9999, :height).should be_nil
  end

  it "can delete all of a node's properties" do
    Neography::Node.set_properties(2, {:age => 32, :name => "Tom", :weight => 200} ).should be_nil
    Neography::Node.remove_properties(2).should be_nil
    Neography::Node.properties(2).should be_nil
  end

  it "can delete an unrelated node" do
    newnode = Neography::Node.new
    Neography::Node.del(newnode[:neo_id]).should be_nil
  end

  it "returns nil if it tries to delete a node that does not exist" do
    Neography::Node.del(9999).should be_nil
  end

  it "returns nil if it tries to delete a node that has already been deleted" do
    newnode = Neography::Node.new
    Neography::Node.del(newnode[:neo_id]).should be_nil
    Neography::Node.del(newnode[:neo_id]).should be_nil
  end

  it "returns nil if it tries to delete a node that has existing relationships" do
    node1 = Neography::Node.new
    node2 = Neography::Node.new
    Neography::Relationship.new(:friends, node1, node2)
    Neography::Node.del(node1[:neo_id]).should be_nil
    Neography::Node.del(node2[:neo_id]).should be_nil
  end

end
