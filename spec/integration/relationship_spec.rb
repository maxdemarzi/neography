require 'spec_helper'

describe Neography::Relationship do
  describe "create relationship" do
    it "#new(:family, p1, p2) creates a new relationship between to nodes of given type" do
      p1 = Neography::Node.create
      p2 = Neography::Node.create

      Neography::Relationship.create(:family, p1, p2)
      expect(p1.outgoing(:family)).to include(p2)
      expect(p2.incoming(:family)).to include(p1)
    end

    it "#new(:family, p1, p2, :since => '1998', :colour => 'blue') creates relationship and sets its properties" do
      p1 = Neography::Node.create
      p2 = Neography::Node.create
      rel = Neography::Relationship.create(:family, p1, p2, :since => 1998, :colour => 'blue')

      expect(rel[:since]).to eq(1998)
      expect(rel[:colour]).to eq('blue')
      expect(rel.since).to eq(1998)
      expect(rel.colour).to eq('blue')
    end

    it "#outgoing(:friends).create(other) creates a new relationship between self and other node" do
      p1 = Neography::Node.create
      p2 = Neography::Node.create
      rel = p1.outgoing(:foo).create(p2)

      expect(rel).to be_kind_of(Neography::Relationship)
      expect(p1.outgoing(:foo).first).to eq(p2)
      expect(p1.outgoing(:foo)).to include(p2)
      expect(p2.incoming(:foo)).to include(p1)
    end
  end

end
