require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "list_labels" do
    it "can get the labels of the database" do
      @neo.set_label(0, "Person")
      labels = @neo.list_labels
      expect(labels).to include("Person")
    end
  end

  describe "add_label" do
    it "can add a label to a node" do
      new_node = @neo.create_node
      @neo.add_label(new_node, "Person")
      labels = @neo.get_node_labels(new_node)
      expect(labels).to eq(["Person"])
    end

    it "can add another label to a node" do
      new_node = @neo.create_node
      new_node_id = new_node["self"].split('/').last
      @neo.add_label(new_node_id, "Actor")
      @neo.add_label(new_node_id, "Director")
      labels = @neo.get_node_labels(new_node_id)
      expect(labels).to eq(["Actor", "Director"])
    end

    it "can add multiple labels to a node" do
      new_node = @neo.create_node
      new_node_id = new_node["self"].split('/').last
      @neo.add_label(new_node_id, ["Actor", "Director"])
      labels = @neo.get_node_labels(new_node_id)
      expect(labels).to eq(["Actor", "Director"])
    end
  end

  describe "set_label" do
    it "can set a label to a node" do
      new_node = @neo.create_node
      new_node_id = new_node["self"].split('/').last
      @neo.set_label(new_node_id, "Person")
      labels = @neo.get_node_labels(new_node_id)
      expect(labels).to eq(["Person"])
    end

    it "can set a label to a node that already had a label" do
      new_node = @neo.create_node
      @neo.add_label(new_node, "Actor")
      @neo.set_label(new_node, "Director")
      labels = @neo.get_node_labels(new_node)
      expect(labels).to eq(["Director"])
    end

    it "can set multiple labels to a node" do
      new_node = @neo.create_node
      new_node_id = new_node["self"].split('/').last
      @neo.set_label(new_node_id, ["Actor", "Director"])
      labels = @neo.get_node_labels(new_node_id)
      expect(labels).to eq(["Actor", "Director"])
    end
  end

  describe "delete_label" do
    it "can delete a label from a node" do
      new_node = @neo.create_node
      @neo.set_label(new_node, ["Actor", "Director"])
      @neo.delete_label(new_node, "Actor")
      labels = @neo.get_node_labels(new_node)
      expect(labels).to eq(["Director"])
    end

    it "can delete a label from a node that doesn't have one" do
      new_node = @neo.create_node
      new_node_id = new_node["self"].split('/').last
      @neo.delete_label(new_node_id, "Actor")
      labels = @neo.get_node_labels(new_node_id)
      expect(labels).to eq([])
    end

    it "cannot delete a label from a node that doesn't exist" do
      new_node = @neo.create_node
      new_node_id = new_node["self"].split('/').last
      expect {
        @neo.delete_label(new_node_id.to_i + 1, "Actor")
      }.to raise_error Neography::NodeNotFoundException
    end
  end

  describe "get_nodes_labeled" do
    it "can get a node with a label" do
      new_node = @neo.create_node
      new_node_id = new_node["self"].split('/').last
      @neo.set_label(new_node_id, ["Actor", "Director"])
      nodes = @neo.get_nodes_labeled("Actor")
      expect(nodes.last["self"].split('/').last).to eq(new_node_id)
    end

    it "returns an empty array on non-existing label" do
      nodes = @neo.get_nodes_labeled("do_not_exist")
      expect(nodes).to eq([])
    end
  end

  describe "find_nodes_labeled" do
    it "can find a node with a label and a property" do
      new_node = @neo.create_node(:name => "max")
      new_node_id = new_node["self"].split('/').last
      @neo.set_label(new_node_id, "clown")
      nodes = @neo.find_nodes_labeled("clown", { :name => "max" })
      expect(nodes.last["self"].split('/').last).to eq(new_node_id)
    end

    it "returns an empty array on non-existing label property" do
      new_node = @neo.create_node(:name => "max")
      new_node_id = new_node["self"].split('/').last
      @neo.set_label(new_node_id, "clown")
      nodes = @neo.find_nodes_labeled("clown", { :name => "does_not_exist" })
      expect(nodes).to eq([])
    end

  end

end
