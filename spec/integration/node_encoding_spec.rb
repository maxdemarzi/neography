# encoding: utf-8
require 'spec_helper'

describe Neography::Node do

  describe "create and new" do

    it "can create a node with UTF-8 encoded properties" do
      new_node = Neography::Node.create("name" => "美都池水")
      expect(new_node.name).to eq("美都池水")
    end

    it "can create a node with more than one UTF-8 encoded properties" do
      new_node = Neography::Node.create("first_name" => "美都", "last_name" => "池水")
      expect(new_node.first_name).to eq("美都")
      expect(new_node.last_name).to eq("池水")
    end

  end

  describe "load" do
    it "can get a node with UTF-8 encoded properties that exists" do
      new_node = Neography::Node.create("first_name" => "美都", "last_name" => "池水")
      existing_node = Neography::Node.load(new_node)
      expect(existing_node).not_to be_nil
      expect(existing_node.neo_id).not_to be_nil
      expect(existing_node.neo_id).to eq(new_node.neo_id)
      expect(existing_node.first_name).to eq("美都")
      expect(existing_node.last_name).to eq("池水")
    end

    it "can get a node with UTF-8 encoded properties from an index" do
      @neo = Neography::Rest.new
      new_node = Neography::Node.create("first_name" => "美都", "last_name" => "池水")
      key = generate_text(6)
      value = generate_text
      @neo.add_node_to_index("test_node_index", key, value, new_node)
      node_from_index = @neo.get_node_index("test_node_index", key, value)
      existing_node = Neography::Node.load(node_from_index)
      expect(existing_node).not_to be_nil
      expect(existing_node.neo_id).not_to be_nil
      expect(existing_node.neo_id).to eq(new_node.neo_id)
      expect(existing_node.first_name).to eq("美都")
      expect(existing_node.last_name).to eq("池水")
    end

    it "can get a node with UTF-8 encoded properties that exists via cypher" do
      new_node = Neography::Node.create("first_name" => "美都", "last_name" => "池水")
      cypher = "START n = node({id}) return n"
      @neo = Neography::Rest.new
      results = @neo.execute_query(cypher, {:id => new_node.neo_id.to_i})
      existing_node = Neography::Node.load(results)
      expect(existing_node).not_to be_nil
      expect(existing_node.neo_id).not_to be_nil
      expect(existing_node.neo_id).to eq(new_node.neo_id)
      expect(existing_node.first_name).to eq("美都")
      expect(existing_node.last_name).to eq("池水")
    end

    it "can get columns of data from a node with UTF-8 encoded properties that exists via cypher" do
      new_node = Neography::Node.create("first_name" => "美都", "last_name" => "池水")
      cypher = "START me = node({id})
                    RETURN me.first_name, me.last_name"
      @neo = Neography::Rest.new
      results = @neo.execute_query(cypher, {:id => new_node.neo_id.to_i})
      expect(results['data'][0]).to eq(["美都","池水"])
    end

  end

end
