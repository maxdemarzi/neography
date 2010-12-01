require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Node do

  describe "create and new" do
    it "can create an empty node" do
      new_node = Neography::Node.create
      new_node.should_not be_nil
    end

    it "can create a node with one property" do
      new_node = Neography::Node.create("name" => "Max")
      new_node.name.should == "Max"
    end

    it "can create a node with more than one property" do
      new_node = Neography::Node.create("age" => 31, "name" => "Max")
      new_node.name.should == "Max"
      new_node.age.should == 31
    end

    it "can create a node with more than one property not on the default rest server" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create({"age" => 31, "name" => "Max"}, @neo)
      new_node.name.should == "Max"
      new_node.age.should == 31
    end

    it "can create a node with more than one property not on the default rest server the other way" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create(@neo, {"age" => 31, "name" => "Max"})
      new_node.name.should == "Max"
      new_node.age.should == 31
    end
  end


  describe "get_node" do
    it "can get a node that exists" do
      new_node = Neography::Node.create
      existing_node = Neography::Node.load(new_node)
      existing_node.should_not be_nil
      existing_node.neo_id.should_not be_nil
      existing_node.neo_id.should == new_node.neo_id
    end

    it "returns nil if it tries to get a node that does not exist" do
      new_node = Neography::Node.create
      fake_node = new_node.neo_id.to_i + 1000
      existing_node = Neography::Node.load(fake_node)
      existing_node.should be_nil
    end

    it "can get a node that exists not on the default rest server" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create(@neo)
      existing_node = Neography::Node.load(new_node, @neo)
      existing_node.should_not be_nil
      existing_node.neo_id.should_not be_nil
      existing_node.neo_id.should == new_node.neo_id
    end

    it "can get a node that exists not on the default rest server the other way" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create(@neo)
      existing_node = Neography::Node.load(@neo, new_node)
      existing_node.should_not be_nil
      existing_node.neo_id.should_not be_nil
      existing_node.neo_id.should == new_node.neo_id
    end


  end

end