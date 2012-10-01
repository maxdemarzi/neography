require 'spec_helper'

module Neography
  describe "Properties" do

    before do
      @db = mock(Neography::Rest, :is_a? => true).as_null_object
      Rest.stub(:new) { @db }
    end

    context "Node" do

      subject(:node) do
        node = Node.create
        node.stub(:neo_id => 42)
        node
      end

      it "sets properties as accessor" do
        @db.should_receive(:"set_node_properties").with(42, { "key" => "value" })
        node.key = "value"
      end

      it "sets properties as array entry" do
        @db.should_receive(:"set_node_properties").with(42, { "key" => "value" })
        node["key"] = "value"
      end

      it "gets properties as accessor" do
        @db.stub(:"set_node_properties").with(42, { "key" => "value" })
        node.key = "value"
        node.key.should == "value"
      end

      it "gets properties as array entry" do
        @db.stub(:"set_node_properties").with(42, { "key" => "value" })
        node["key"] = "value"
        node["key"].should == "value"
      end

      it "resets properties as accessor" do
        @db.should_receive(:"remove_node_properties").with(42, ["key"])
        node.key = nil
      end

      it "resets properties as array entry" do
        @db.should_receive(:"remove_node_properties").with(42, ["key"])
        node["key"] = nil
      end

      it "gets unknown properties as nil" do
        node.unknown.should == nil
      end

      it "overwrites existing properties" do
        @db.should_receive(:"set_node_properties").with(42, { "key" => "value1" })
        node.key = "value1"

        @db.should_receive(:"set_node_properties").with(42, { "key" => "value2" })
        node.key = "value2"
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
        @db.should_receive(:"set_relationship_properties").with(42, { "key" => "value" })
        relationship.key = "value"
      end

      it "sets properties as array entry" do
        @db.should_receive(:"set_relationship_properties").with(42, { "key" => "value" })
        relationship["key"] = "value"
      end

      it "gets properties as accessor" do
        @db.stub(:"set_relationship_properties").with(42, { "key" => "value" })
        relationship.key = "value"
        relationship.key.should == "value"
      end

      it "gets properties as array entry" do
        @db.stub(:"set_relationship_properties").with(42, { "key" => "value" })
        relationship["key"] = "value"
        relationship["key"].should == "value"
      end

      it "resets properties as accessor" do
        @db.should_receive(:"remove_relationship_properties").with(42, ["key"])
        relationship.key = nil
      end

      it "resets properties as array entry" do
        @db.should_receive(:"remove_relationship_properties").with(42, ["key"])
        relationship["key"] = nil
      end

      it "gets unknown properties as nil" do
        relationship.unknown.should == nil
      end

      it "overwrites existing properties" do
        @db.should_receive(:"set_relationship_properties").with(42, { "key" => "value1" })
        relationship.key = "value1"

        @db.should_receive(:"set_relationship_properties").with(42, { "key" => "value2" })
        relationship.key = "value2"
      end

    end
  end
end
