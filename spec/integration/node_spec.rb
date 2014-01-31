require 'spec_helper'

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

    it "cannot create a node with more than one property not on the default rest server the other way" do
      @neo = Neography::Rest.new
      expect {
        new_node = Neography::Node.create(@neo, {"age" => 31, "name" => "Max"})
      }.to raise_error(ArgumentError)
    end
  end


  describe "load" do
    it "can get a node that exists" do
      new_node = Neography::Node.create
      existing_node = Neography::Node.load(new_node)
      existing_node.should_not be_nil
      existing_node.neo_id.should_not be_nil
      existing_node.neo_id.should == new_node.neo_id
    end

    it "raises an error if it tries to load a node that does not exist" do
      new_node = Neography::Node.create
      fake_node = new_node.neo_id.to_i + 1000
      expect {
        existing_node = Neography::Node.load(fake_node)
      }.to raise_error Neography::NodeNotFoundException
    end

    it "can load a node that exists not on the default rest server" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create({}, @neo)
      existing_node = Neography::Node.load(new_node, @neo)
      existing_node.should_not be_nil
      existing_node.neo_id.should_not be_nil
      existing_node.neo_id.should == new_node.neo_id
    end

    it "cannot load a node that exists not on the default rest server the other way" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create({}, @neo)
      expect {
        existing_node = Neography::Node.load(@neo, new_node)
      }.to raise_error(ArgumentError)
    end

    it "can get a node from an index" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create("age" => 31, "name" => "Max")
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node) 
      node_from_index = @neo.get_node_index("test_node_index", key, value) 
      existing_node = Neography::Node.load(node_from_index)
      existing_node.should_not be_nil
      existing_node.neo_id.should_not be_nil
      existing_node.neo_id.should == new_node.neo_id
    end

    it "can get a node that exists via cypher" do
      new_node = Neography::Node.create("age" => 31, "name" => "Max")
      cypher = "START n = node({id}) return n"
      @neo = Neography::Rest.new
      results = @neo.execute_query(cypher, {:id => new_node.neo_id.to_i})
      existing_node = Neography::Node.load(results)
      existing_node.should_not be_nil
      existing_node.neo_id.should_not be_nil
      existing_node.neo_id.should == new_node.neo_id
    end


  end

  describe "del" do
    it "can delete itself" do
      new_node = Neography::Node.create
      node_id = new_node.neo_id
      new_node.del
      expect {
        Neography::Node.load(node_id)
      }.to raise_error Neography::NodeNotFoundException
    end
  end

  describe "exists?" do
    it "can tell if it exists" do
      new_node = Neography::Node.create
      new_node.exist?.should be_true
    end

    it "can tell if does not exists" do
      new_node = Neography::Node.create
      new_node.del
      new_node.exist?.should be_false
    end
  end

  describe "equality" do
    it "can tell two nodes are the same with equal?" do
      new_node = Neography::Node.create
      another_node = Neography::Node.load(new_node)
      new_node.equal?(another_node).should be_true 
    end

    it "can tell two nodes are the same with eql?" do
      new_node = Neography::Node.create
      another_node = Neography::Node.load(new_node)
      new_node.eql?(another_node).should be_true 
    end

    it "can tell two nodes are the same with ==" do
      new_node = Neography::Node.create
      another_node = Neography::Node.load(new_node)
      (new_node == another_node).should be_true 
    end
  end

  describe "set properties" do
    it "can change a node's properties that already exist using []=" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node[:weight] = 200
      new_node[:eyes] = "brown"

      existing_node = Neography::Node.load(new_node)
      existing_node.weight.should == 200
      existing_node.eyes.should == "brown"
    end

    it "can change a node's properties that already exist" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node.weight = 200
      new_node.eyes = "brown"

      existing_node = Neography::Node.load(new_node)
      existing_node.weight.should == 200
      existing_node.eyes.should == "brown"
    end

    it "can change a node's properties that does not already exist using []=" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node.weight = 200
      new_node.eyes = "brown"
      new_node[:hair] = "black"

      existing_node = Neography::Node.load(new_node)
      existing_node.weight.should == 200
      existing_node.eyes.should == "brown"
      existing_node.hair.should == "black"
    end

    it "can change a node's properties that does not already exist" do
      new_node = Neography::Node.create

      new_node.hair = "black"

      existing_node = Neography::Node.load(new_node)
      existing_node.hair.should == "black"
    end

    it "can pass issue 18" do
      n = Neography::Node.create("name" => "Test")
      n.prop = 1
      n.prop.should == 1           
      n.prop = 1                   
      n.prop.should == 1           
      n[:prop].should == 1         
      n[:prop2] = 2                  
      n[:prop2].should == 2          
      n[:prop2] = 2                  
      n[:prop2].should == 2          
      n.name                         
      n.name = "New Name"            
      n.name.should == "New Name"
    end

  end

  describe "get node properties" do
    it "can get node properties using []" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")
      new_node[:weight].should == 150
      new_node[:eyes].should == "green"
    end

    it "can get node properties" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")
      new_node.weight.should == 150
      new_node.eyes.should == "green"
    end
  end

  describe "delete node properties" do
    it "can delete node properties using []" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node[:weight] = nil
      new_node[:eyes] = nil

      new_node[:weight].should be_nil
      new_node[:eyes].should be_nil

      existing_node = Neography::Node.load(new_node)
      existing_node.weight.should be_nil
      existing_node.eyes.should be_nil
    end

    it "can delete node properties" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node.weight = nil
      new_node.eyes = nil

      new_node.weight.should be_nil
      new_node.eyes.should be_nil

      existing_node = Neography::Node.load(new_node)
      existing_node.weight.should be_nil
      existing_node.eyes.should be_nil
    end
  end

  describe 'gets labels' do
    let(:subject) {
      node = Neography::Node.create
      node.neo_server.add_label(node, 'Label')
      node.neo_server.add_label(node, 'Label2')
      node
    }

    it { subject.labels.should == %w(Label Label2) }
  end
end
