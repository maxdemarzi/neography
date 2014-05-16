require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "list relationship types" do
    it "can get a listing of relationship types" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2)
      rel_types = @neo.list_relationship_types
      expect(rel_types).not_to be_nil
      expect(rel_types).to include("friends")
    end
  end
end