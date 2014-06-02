require 'spec_helper'

describe Neography::NodeRelationship do

    def create_nodes
      #
      #                f
      #                ^
      #              friends
      #                |
      #  a --friends-> b  --friends--> c
      #                |              ^
      #                |              |
      #                +--- work  -----+
      #                |
      #                +--- work  ---> d  --- work --> e
      a = Neography::Node.create :name => 'a'
      b = Neography::Node.create :name => 'b'
      c = Neography::Node.create :name => 'c'
      d = Neography::Node.create :name => 'd'
      e = Neography::Node.create :name => 'e'
      f = Neography::Node.create :name => 'f'
      a.outgoing(:friends) << b
      b.outgoing(:friends) << c
      b.outgoing(:work) << c
      b.outgoing(:work) << d
      d.outgoing(:work) << e
      b.outgoing(:friends) << f
      [a,b,c,d,e,f]
    end

  describe "outgoing" do
    it "#outgoing(:friends) << other_node creates an outgoing relationship of type :friends" do
      a = Neography::Node.create
      other_node = Neography::Node.create

      # when
      a.outgoing(:friends) << other_node

      # then
      expect(a.outgoing(:friends).first).to eq(other_node)
    end

    it "#outgoing(:friends) << b << c creates an outgoing relationship of type :friends" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create

      # when
      a.outgoing(:friends) << b << c

      # then
      expect(a.outgoing(:friends)).to include(b,c)
    end

    it "#outgoing returns all incoming nodes of any type" do
      a,b,c,d,e,f = create_nodes

      expect(b.outgoing).to include(c,f,d)
      expect([*b.outgoing].size).to eq(4) #c is related by both work and friends
    end

    it "#outgoing(type) should only return outgoing nodes of the given type of depth one" do
      a,b,c,d = create_nodes
      expect(b.outgoing(:work)).to include(c,d)
      expect([*b.outgoing(:work)].size).to eq(2)
    end

    it "#outgoing(type1).outgoing(type2) should return outgoing nodes of the given types" do
      a,b,c,d,e,f = create_nodes
      nodes = b.outgoing(:work).outgoing(:friends)
     
      expect(nodes).to include(c,d,f)
      expect(nodes.size).to eq(4) #c is related by both work and friends
    end

    it "#outgoing(type).depth(4) should only return outgoing nodes of the given type and depth" do
      a,b,c,d,e = create_nodes
      expect([*b.outgoing(:work).depth(4)].size).to eq(3)
      expect(b.outgoing(:work).depth(4)).to include(c,d,e)
    end

    it "#outgoing(type).depth(4).include_start_node should also include the start node" do
      a,b,c,d,e = create_nodes
      expect([*b.outgoing(:work).depth(4).include_start_node].size).to eq(4)
      expect(b.outgoing(:work).depth(4).include_start_node).to include(b,c,d,e)
    end

    it "#outgoing(type).depth(:all) should traverse at any depth" do
      a,b,c,d,e = create_nodes
      expect([*b.outgoing(:work).depth(:all)].size).to eq(3)
      expect(b.outgoing(:work).depth(:all)).to include(c,d,e)
    end
  end

  describe "incoming" do
    it "#incoming(:friends) << other_node should add an incoming relationship" do
      a = Neography::Node.create
      other_node = Neography::Node.create

      # when
      a.incoming(:friends) << other_node

      # then
      expect(a.incoming(:friends).first).to eq(other_node)
    end

    it "#incoming(:friends) << b << c creates an incoming relationship of type :friends" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create

      # when
      a.incoming(:friends) << b << c

      # then
      expect(a.incoming(:friends)).to include(b,c)
    end

    it "#incoming returns all incoming nodes of any type" do
      a,b,c,d,e,f = create_nodes

      expect(b.incoming).to include(a)
      expect([*b.incoming].size).to eq(1)
    end

    it "#incoming(type).depth(2) should only return outgoing nodes of the given type and depth" do
      a,b,c,d,e = create_nodes
      expect([*e.incoming(:work).depth(2)].size).to eq(2)
      expect(e.incoming(:work).depth(2)).to include(b,d)
    end

    it "#incoming(type) should only return incoming nodes of the given type of depth one" do
      a,b,c,d = create_nodes
      expect(c.incoming(:work)).to include(b)
      expect([*c.incoming(:work)].size).to eq(1)
    end
  end

  describe "both" do
    it "#both(:friends) << other_node should raise an exception" do
      a = Neography::Node.create
      other_node = Neography::Node.create

      # when
      a.both(:friends) << other_node
      expect(a.incoming(:friends).first).to eq(other_node)
      expect(a.outgoing(:friends).first).to eq(other_node)
    end

    it "#both returns all incoming and outgoing nodes of any type" do
      a,b,c,d,e,f = create_nodes

      expect(b.both).to include(a,c,d,f)
      expect([*b.both].size).to eq(5) #c is related by both work and friends
      expect(b.incoming).to include(a)
      expect(b.outgoing).to include(c)
    end

    it "#both returns an empty array for unconnected nodes" do
      a = Neography::Node.create
      expect(a.both.size).to eq(0)
    end

    it "#both(type) should return both incoming and outgoing nodes of the given type of depth one" do
      a,b,c,d,e,f = create_nodes

      expect(b.both(:friends)).to include(a,c,f)
      expect([*b.both(:friends)].size).to eq(3)
    end

    it "#outgoing and #incoming can be combined to traverse several relationship types" do
      a,b,c,d,e = create_nodes
      nodes = [*b.incoming(:friends).outgoing(:work)]

      expect(nodes).to include(a,c,d)
      expect(nodes).not_to include(b,e)
    end
  end


  describe "prune" do
    it "#prune, if it returns true the traversal will be stop for that path" do
      a, b, c, d, e = create_nodes
      expect([*b.outgoing(:work).depth(4)].size).to eq(3)
      expect(b.outgoing(:work).depth(4)).to include(c,d,e)

      expect([*b.outgoing(:work).prune("position.endNode().getProperty('name') == 'd';")].size).to eq(2)
      expect(b.outgoing(:work).prune("position.endNode().getProperty('name') == 'd';")).to include(c,d)
    end
  end

  describe "filter" do
    it "#filter, if it returns true the node will be included in the return results" do
      a, b, c, d, e = create_nodes
      expect([*b.outgoing(:work).depth(4)].size).to eq(3)
      expect(b.outgoing(:work).depth(4)).to include(c,d,e)

      expect([*b.outgoing(:work).depth(4).filter("position.length() == 2;")].size).to eq(1)
      expect(b.outgoing(:work).depth(4).filter("position.length() == 2;")).to include(e)
    end
  end

  describe "rels" do
    it "#rels returns a RelationshipTraverser which can filter which relationship it should return by specifying #to_other" do
      a = Neography::Node.create      
      b = Neography::Node.create
      c = Neography::Node.create
      r1 = Neography::Relationship.create(:friend, a, b)
      Neography::Relationship.create(:friend, a, c)

      expect(a.rels.to_other(b).size).to eq(1)
      expect(a.rels.to_other(b)).to include(r1)
    end

    it "#rels returns an RelationshipTraverser which provides a method for deleting all the relationships" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create
      r1 = Neography::Relationship.create(:friend, a, b)
      r2 = Neography::Relationship.create(:friend, a, c)

      expect(a.rel?(:friend)).to be true
      a.rels.del
      expect(a.rel?(:friend)).to be false
      expect(r1.exist?).to be false
      expect(r2.exist?).to be false
    end

    it "#rels returns an RelationshipTraverser with methods #del and #to_other which can be combined to only delete a subset of the relationships" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create
      r1 = Neography::Relationship.create(:friend, a, b)
      r2 = Neography::Relationship.create(:friend, a, c)
      expect(r1.exist?).to be true
      expect(r2.exist?).to be true
      a.rels.to_other(c).del
      expect(r1.exist?).to be true
      expect(r2.exist?).to be false
    end

 it "#rels should return both incoming and outgoing relationship of any type of depth one" do
      a,b,c,d,e,f = create_nodes
      expect(b.rels.size).to eq(5)
      nodes = b.rels.collect{|r| r.other_node(b)}
      expect(nodes).to include(a,c,d,f)
      expect(nodes).not_to include(e)
    end

    it "#rels(:friends) should return both incoming and outgoing relationships of given type of depth one" do
      # given
      a,b,c,d,e,f = create_nodes

      # when
      rels = [*b.rels(:friends)]

      # then
      expect(rels.size).to eq(3)
      nodes = rels.collect{|r| r.end_node}
      expect(nodes).to include(b,c,f)
      expect(nodes).not_to include(a,d,e)
    end

    it "#rels(:friends).outgoing should return only outgoing relationships of given type of depth one" do
      # given
      a,b,c,d,e,f = create_nodes

      # when
      rels = [*b.rels(:friends).outgoing]

      # then
      expect(rels.size).to eq(2)
      nodes = rels.collect{|r| r.end_node}
      expect(nodes).to include(c,f)
      expect(nodes).not_to include(a,b,d,e)
    end


    it "#rels(:friends).incoming should return only outgoing relationships of given type of depth one" do
      # given
      a,b,c,d,e = create_nodes

      # when
      rels = [*b.rels(:friends).incoming]

      # then
      expect(rels.size).to eq(1)
      nodes = rels.collect{|r| r.start_node}
      expect(nodes).to include(a)
      expect(nodes).not_to include(b,c,d,e)
    end

    it "#rels(:friends,:work) should return both incoming and outgoing relationships of given types of depth one" do
      # given
      a,b,c,d,e,f = create_nodes

      # when
      rels = [*b.rels(:friends,:work)]

      # then
      expect(rels.size).to eq(5)
      nodes = rels.collect{|r| r.other_node(b)}
      expect(nodes).to include(a,c,d,f)
      expect(nodes).not_to include(b,e)
    end

    it "#rels(:friends,:work).outgoing should return outgoing relationships of given types of depth one" do
      # given
      a,b,c,d,e,f = create_nodes

      # when
      rels = [*b.rels(:friends,:work).outgoing]

      # then
      expect(rels.size).to eq(4)
      nodes = rels.collect{|r| r.other_node(b)}
      expect(nodes).to include(c,d,f)
      expect(nodes).not_to include(a,b,e)
    end
  end

  describe "rel" do
    it "#rel returns a single relationship if there is only one relationship" do
      a = Neography::Node.create
      b = Neography::Node.create
      rel = Neography::Relationship.create(:friend, a, b)
      expect(a.rel(:outgoing, :friend)).to eq(rel)
    end

    it "#rel returns nil if there is no relationship" do
      a = Neography::Node.create
      b = Neography::Node.create
      expect(a.rel(:outgoing, :friend)).to be_empty
    end

    it "#rel should only return one relationship even if there are more" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create
      Neography::Relationship.create(:friend, a, b)
      Neography::Relationship.create(:friend, a, c)
      [*a.rel(:outgoing, :friend)].size == 1
    end
  end

  describe "rel?" do
    it "#rel? returns true if there are any relationships" do
      n1 = Neography::Node.create
      expect(n1.rel?).to be false
      n1.outgoing(:foo) << Neography::Node.create

      expect(n1.rel?).to be true
      expect(n1.rel?(:bar)).to be false
      expect(n1.rel?(:foo)).to be true
      expect(n1.rel?(:incoming, :foo)).to be false
      expect(n1.rel?(:outgoing, :foo)).to be true
      expect(n1.rel?(:foo, :incoming)).to be false
      expect(n1.rel?(:foo, :outgoing)).to be true
      expect(n1.rel?(:incoming)).to be false
      expect(n1.rel?(:outgoing)).to be true
      expect(n1.rel?(:both)).to be true
      expect(n1.rel?(:all)).to be true
      expect(n1.rel?).to be true
    end
  end


  describe "delete relationship" do
    it "can delete an existing relationship" do
      p1 = Neography::Node.create
      p2 = Neography::Node.create
      new_rel = Neography::Relationship.create(:family, p1, p2)
      new_rel.del
      expect {
        Neography::Relationship.load(new_rel)
      }.to raise_error Neography::RelationshipNotFoundException
    end
  end

end
