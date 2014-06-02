require 'spec_helper'

describe Neography::Node do

  describe "create and new" do
    it "can create an empty node" do
      new_node = Neography::Node.create
      expect(new_node).not_to be_nil
    end

    it "can create a node with one property" do
      new_node = Neography::Node.create("name" => "Max")
      expect(new_node.name).to eq("Max")
    end

    it "can create a node with more than one property" do
      new_node = Neography::Node.create("age" => 31, "name" => "Max")
      expect(new_node.name).to eq("Max")
      expect(new_node.age).to eq(31)
    end

    it "can create a node with more than one property not on the default rest server" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create({"age" => 31, "name" => "Max"}, @neo)
      expect(new_node.name).to eq("Max")
      expect(new_node.age).to eq(31)
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
      expect(existing_node).not_to be_nil
      expect(existing_node.neo_id).not_to be_nil
      expect(existing_node.neo_id).to eq(new_node.neo_id)
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
      expect(existing_node).not_to be_nil
      expect(existing_node.neo_id).not_to be_nil
      expect(existing_node.neo_id).to eq(new_node.neo_id)
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
      expect(existing_node).not_to be_nil
      expect(existing_node.neo_id).not_to be_nil
      expect(existing_node.neo_id).to eq(new_node.neo_id)
    end

    it "can get a node that exists via cypher" do
      new_node = Neography::Node.create("age" => 31, "name" => "Max")
      cypher = "START n = node({id}) return n"
      @neo = Neography::Rest.new
      results = @neo.execute_query(cypher, {:id => new_node.neo_id.to_i})
      existing_node = Neography::Node.load(results)
      expect(existing_node).not_to be_nil
      expect(existing_node.neo_id).not_to be_nil
      expect(existing_node.neo_id).to eq(new_node.neo_id)
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
      expect(new_node.exist?).to be true
    end

    it "can tell if does not exists" do
      new_node = Neography::Node.create
      new_node.del
      expect(new_node.exist?).to be false
    end
  end

  describe "equality" do
    it "can tell two nodes are the same with equal?" do
      new_node = Neography::Node.create
      another_node = Neography::Node.load(new_node)
      expect(new_node.equal?(another_node)).to be true 
    end

    it "can tell two nodes are the same with eql?" do
      new_node = Neography::Node.create
      another_node = Neography::Node.load(new_node)
      expect(new_node.eql?(another_node)).to be true 
    end

    it "can tell two nodes are the same with ==" do
      new_node = Neography::Node.create
      another_node = Neography::Node.load(new_node)
      expect(new_node == another_node).to be true 
    end
  end

  describe "set properties" do
    it "can change a node's properties that already exist using []=" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node[:weight] = 200
      new_node[:eyes] = "brown"

      existing_node = Neography::Node.load(new_node)
      expect(existing_node.weight).to eq(200)
      expect(existing_node.eyes).to eq("brown")
    end

    it "can change a node's properties that already exist" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node.weight = 200
      new_node.eyes = "brown"

      existing_node = Neography::Node.load(new_node)
      expect(existing_node.weight).to eq(200)
      expect(existing_node.eyes).to eq("brown")
    end

    it "can change a node's properties that does not already exist using []=" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node.weight = 200
      new_node.eyes = "brown"
      new_node[:hair] = "black"

      existing_node = Neography::Node.load(new_node)
      expect(existing_node.weight).to eq(200)
      expect(existing_node.eyes).to eq("brown")
      expect(existing_node.hair).to eq("black")
    end

    it "can change a node's properties that does not already exist" do
      new_node = Neography::Node.create

      new_node.hair = "black"

      existing_node = Neography::Node.load(new_node)
      expect(existing_node.hair).to eq("black")
    end

    it "can pass issue 18" do
      n = Neography::Node.create("name" => "Test")
      n.prop = 1
      expect(n.prop).to eq(1)           
      n.prop = 1                   
      expect(n.prop).to eq(1)           
      expect(n[:prop]).to eq(1)         
      n[:prop2] = 2                  
      expect(n[:prop2]).to eq(2)          
      n[:prop2] = 2                  
      expect(n[:prop2]).to eq(2)          
      n.name                         
      n.name = "New Name"            
      expect(n.name).to eq("New Name")
    end

  end

  describe "get node properties" do
    it "can get node properties using []" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")
      expect(new_node[:weight]).to eq(150)
      expect(new_node[:eyes]).to eq("green")
    end

    it "can get node properties" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")
      expect(new_node.weight).to eq(150)
      expect(new_node.eyes).to eq("green")
    end
  end

  describe "delete node properties" do
    it "can delete node properties using []" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node[:weight] = nil
      new_node[:eyes] = nil

      expect(new_node[:weight]).to be_nil
      expect(new_node[:eyes]).to be_nil

      existing_node = Neography::Node.load(new_node)
      expect(existing_node.weight).to be_nil
      expect(existing_node.eyes).to be_nil
    end

    it "can delete node properties" do
      new_node = Neography::Node.create("weight" => 150, "eyes" => "green")

      new_node.weight = nil
      new_node.eyes = nil

      expect(new_node.weight).to be_nil
      expect(new_node.eyes).to be_nil

      existing_node = Neography::Node.load(new_node)
      expect(existing_node.weight).to be_nil
      expect(existing_node.eyes).to be_nil
    end
  end

  describe 'gets labels' do
    let(:subject) {
      node = Neography::Node.create
      node.neo_server.add_label(node, 'Label')
      node.neo_server.add_label(node, 'Label2')
      node
    }

    it { expect(subject.labels).to eq(%w(Label Label2)) }
  end
end
