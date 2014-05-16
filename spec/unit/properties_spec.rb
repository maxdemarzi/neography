require 'spec_helper'

module Neography
  describe "Properties" do

    before do
      @db = double(Neography::Rest, :is_a? => true).as_null_object
      allow(Rest).to receive(:new) { @db }
    end

    context "Node" do

      subject(:node) do
        node = Node.create
        node.stub(:neo_id => 42)
        node
      end

      it "sets properties as accessor" do
        expect(@db).to receive(:"set_node_properties").with(42, { "key" => "value" })
        node.key = "value"
      end

      it "sets properties as array entry" do
        expect(@db).to receive(:"set_node_properties").with(42, { "key" => "value" })
        node["key"] = "value"
      end

      it "gets properties as accessor" do
        allow(@db).to receive(:"set_node_properties")
        node.key = "value"
        expect(node.key).to eq("value")
      end

      it "gets properties as array entry" do
        allow(@db).to receive(:"set_node_properties")
        node["key"] = "value"
        expect(node["key"]).to eq("value")
      end

      it "resets properties as accessor" do
        expect(@db).to receive(:"remove_node_properties").with(42, ["key"])
        node.key = "value"
        node.key = nil
      end

      it "resets properties as array entry" do
        expect(@db).to receive(:"remove_node_properties").with(42, ["key"])
        node["key"] = "value"
        node["key"] = nil
      end

      it "gets unknown properties as nil" do
        expect(node.unknown).to eq(nil)
      end

      it "overwrites existing properties" do
        expect(@db).to receive(:"set_node_properties").with(42, { "key" => "value1" })
        node.key = "value1"

        expect(@db).to receive(:"set_node_properties").with(42, { "key" => "value2" })
        node.key = "value2"
      end

      it "knows its attributes" do
        allow(@db).to receive(:"set_node_properties")
        node.key = "value"
        node["key2"] = "value"
        expect(node.attributes).to match_array([ :key, :key2 ])
      end

    end

    context "Relationship" do

      subject(:relationship) do
        from = Node.create
        to = Node.create

        rel = Relationship.create(:type, from, to)
        rel.stub(:neo_id => 42)
        rel
      end

      it "sets properties as accessor" do
        expect(@db).to receive(:"set_relationship_properties").with(42, { "key" => "value" })
        relationship.key = "value"
      end

      it "sets properties as array entry" do
        expect(@db).to receive(:"set_relationship_properties").with(42, { "key" => "value" })
        relationship["key"] = "value"
      end

      it "gets properties as accessor" do
        allow(@db).to receive(:"set_relationship_properties")
        relationship.key = "value"
        expect(relationship.key).to eq("value")
      end

      it "gets properties as array entry" do
        allow(@db).to receive(:"set_relationship_properties")
        relationship["key"] = "value"
        expect(relationship["key"]).to eq("value")
      end

      it "resets properties as accessor" do
        expect(@db).to receive(:"remove_relationship_properties").with(42, ["key"])
        relationship.key = "value"
        relationship.key = nil
      end

      it "resets properties as array entry" do
        expect(@db).to receive(:"remove_relationship_properties").with(42, ["key"])
        relationship["key"] = "value"
        relationship["key"] = nil
      end

      it "gets unknown properties as nil" do
        expect(relationship.unknown).to eq(nil)
      end

      it "overwrites existing properties" do
        expect(@db).to receive(:"set_relationship_properties").with(42, { "key" => "value1" })
        relationship.key = "value1"

        expect(@db).to receive(:"set_relationship_properties").with(42, { "key" => "value2" })
        relationship.key = "value2"
      end

      it "knows its attributes" do
        allow(@db).to receive(:"set_relationship_properties")
        relationship.key = "value"
        relationship["key2"] = "value"
        expect(relationship.attributes).to match_array([ :key, :key2 ])
      end

    end
  end
end
