require File.join(File.dirname(__FILE__), '..', 'spec_helper')

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
      a.outgoing(:friends).first.should == other_node
    end

    it "#outgoing(:friends) << b << c creates an outgoing relationship of type :friends" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create

      # when
      a.outgoing(:friends) << b << c

      # then
      a.outgoing(:friends).should include(b,c)
    end

    it "#outgoing returns all incoming nodes of any type" do
      a,b,c,d,e,f = create_nodes

      b.outgoing.should include(c,f,d)
      [*b.outgoing].size.should == 4 #c is related by both work and friends
    end

    it "#outgoing(type) should only return outgoing nodes of the given type of depth one" do
      a,b,c,d = create_nodes
      b.outgoing(:work).should include(c,d)
      [*b.outgoing(:work)].size.should == 2
    end

    it "#outgoing(type1).outgoing(type2) should return outgoing nodes of the given types" do
      a,b,c,d,e,f = create_nodes
      nodes = b.outgoing(:work).outgoing(:friends)
     
      nodes.should include(c,d,f)
      nodes.size.should == 4 #c is related by both work and friends
    end

    it "#outgoing(type).depth(4) should only return outgoing nodes of the given type and depth" do
      a,b,c,d,e = create_nodes
      [*b.outgoing(:work).depth(4)].size.should == 3
      b.outgoing(:work).depth(4).should include(c,d,e)
    end

    it "#outgoing(type).depth(4).include_start_node should also include the start node" do
      a,b,c,d,e = create_nodes
      [*b.outgoing(:work).depth(4).include_start_node].size.should == 4
      b.outgoing(:work).depth(4).include_start_node.should include(b,c,d,e)
    end

    it "#outgoing(type).depth(:all) should traverse at any depth" do
      a,b,c,d,e = create_nodes
      [*b.outgoing(:work).depth(:all)].size.should == 3
      b.outgoing(:work).depth(:all).should include(c,d,e)
    end
  end

  describe "incoming" do
    it "#incoming(:friends) << other_node should add an incoming relationship" do
      a = Neography::Node.create
      other_node = Neography::Node.create

      # when
      a.incoming(:friends) << other_node

      # then
      a.incoming(:friends).first.should == other_node
    end

    it "#incoming(:friends) << b << c creates an incoming relationship of type :friends" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create

      # when
      a.incoming(:friends) << b << c

      # then
      a.incoming(:friends).should include(b,c)
    end

    it "#incoming returns all incoming nodes of any type" do
      a,b,c,d,e,f = create_nodes

      b.incoming.should include(a)
      [*b.incoming].size.should == 1
    end

    it "#incoming(type).depth(2) should only return outgoing nodes of the given type and depth" do
      a,b,c,d,e = create_nodes
      [*e.incoming(:work).depth(2)].size.should == 2
      e.incoming(:work).depth(2).should include(b,d)
    end

    it "#incoming(type) should only return incoming nodes of the given type of depth one" do
      a,b,c,d = create_nodes
      c.incoming(:work).should include(b)
      [*c.incoming(:work)].size.should == 1
    end
  end

  describe "both" do
    it "#both(:friends) << other_node should raise an exception" do
      a = Neography::Node.create
      other_node = Neography::Node.create

      # when
      a.both(:friends) << other_node
      a.incoming(:friends).first.should == other_node
      a.outgoing(:friends).first.should == other_node
    end

    it "#both returns all incoming and outgoing nodes of any type" do
      a,b,c,d,e,f = create_nodes

      b.both.should include(a,c,d,f)
      [*b.both].size.should == 5 #c is related by both work and friends
      b.incoming.should include(a)
      b.outgoing.should include(c)
    end

    it "#both(type) should return both incoming and outgoing nodes of the given type of depth one" do
      a,b,c,d,e,f = create_nodes

      b.both(:friends).should include(a,c,f)
      [*b.both(:friends)].size.should == 3
    end

    it "#outgoing and #incoming can be combined to traverse several relationship types" do
      a,b,c,d,e = create_nodes
      nodes = [*b.incoming(:friends).outgoing(:work)]

      nodes.should include(a,c,d)
      nodes.should_not include(b,e)
    end
  end


  describe "prune" do
    it "#prune, if it returns true the traversal will be stop for that path" do
      a, b, c, d, e = create_nodes
      [*b.outgoing(:work).depth(4)].size.should == 3
      b.outgoing(:work).depth(4).should include(c,d,e)

      [*b.outgoing(:work).prune("position.endNode().getProperty('name') == 'd';")].size.should == 2
      b.outgoing(:work).prune("position.endNode().getProperty('name') == 'd';").should include(c,d)
    end
  end

  describe "filter" do
    it "#filter, if it returns true the node will be included in the return results" do
      a, b, c, d, e = create_nodes
      [*b.outgoing(:work).depth(4)].size.should == 3
      b.outgoing(:work).depth(4).should include(c,d,e)

      [*b.outgoing(:work).depth(4).filter("position.length() == 2;")].size.should == 1
      b.outgoing(:work).depth(4).filter("position.length() == 2;").should include(e)
    end
  end

  describe "rels" do
    it "#rels returns a RelationshipTraverser which can filter which relationship it should return by specifying #to_other" do
      a = Neography::Node.create      
      b = Neography::Node.create
      c = Neography::Node.create
      r1 = Neography::Relationship.create(:friend, a, b)
      Neography::Relationship.create(:friend, a, c)

      a.rels.to_other(b).size.should == 1
      a.rels.to_other(b).should include(r1)
    end

    it "#rels returns an RelationshipTraverser which provides a method for deleting all the relationships" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create
      r1 = Neography::Relationship.create(:friend, a, b)
      r2 = Neography::Relationship.create(:friend, a, c)

      a.rel?(:friend).should be_true
      a.rels.del
      a.rel?(:friend).should be_false
      r1.exist?.should be_false
      r2.exist?.should be_false
    end

    it "#rels returns an RelationshipTraverser with methods #del and #to_other which can be combined to only delete a subset of the relationships" do
      a = Neography::Node.create
      b = Neography::Node.create
      c = Neography::Node.create
      r1 = Neography::Relationship.create(:friend, a, b)
      r2 = Neography::Relationship.create(:friend, a, c)
      r1.exist?.should be_true
      r2.exist?.should be_true
      a.rels.to_other(c).del
      r1.exist?.should be_true
      r2.exist?.should be_false
    end

 it "#rels should return both incoming and outgoing relationship of any type of depth one" do
      a,b,c,d,e,f = create_nodes
      b.rels.size.should == 5
      nodes = b.rels.collect{|r| r.other_node(b)}
      nodes.should include(a,c,d,f)
      nodes.should_not include(e)
    end

    it "#rels(:friends) should return both incoming and outgoing relationships of given type of depth one" do
      # given
      a,b,c,d,e,f = create_nodes

      # when
      rels = [*b.rels(:friends)]

      # then
      rels.size.should == 3
      nodes = rels.collect{|r| r.end_node}
      nodes.should include(b,c,f)
      nodes.should_not include(a,d,e)
    end

    it "#rels(:friends).outgoing should return only outgoing relationships of given type of depth one" do
      # given
      a,b,c,d,e,f = create_nodes

      # when
      rels = [*b.rels(:friends).outgoing]

      # then
      rels.size.should == 2
      nodes = rels.collect{|r| r.end_node}
      nodes.should include(c,f)
      nodes.should_not include(a,b,d,e)
    end


    it "#rels(:friends).incoming should return only outgoing relationships of given type of depth one" do
      # given
      a,b,c,d,e = create_nodes

      # when
      rels = [*b.rels(:friends).incoming]

      # then
      rels.size.should == 1
      nodes = rels.collect{|r| r.start_node}
      nodes.should include(a)
      nodes.should_not include(b,c,d,e)
    end

    it "#rels(:friends,:work) should return both incoming and outgoing relationships of given types of depth one" do
      # given
      a,b,c,d,e,f = create_nodes

      # when
      rels = [*b.rels(:friends,:work)]

      # then
      rels.size.should == 5
      nodes = rels.collect{|r| r.other_node(b)}
      nodes.should include(a,c,d,f)
      nodes.should_not include(b,e)
    end

    it "#rels(:friends,:work).outgoing should return outgoing relationships of given types of depth one" do
      # given
      a,b,c,d,e,f = create_nodes

      # when
      rels = [*b.rels(:friends,:work).outgoing]

      # then
      rels.size.should == 4
      nodes = rels.collect{|r| r.other_node(b)}
      nodes.should include(c,d,f)
      nodes.should_not include(a,b,e)
    end
  end

  describe "rel" do
    it "#rel returns a single relationship if there is only one relationship" do
      a = Neography::Node.create
      b = Neography::Node.create
      rel = Neography::Relationship.create(:friend, a, b)
      a.rel(:outgoing, :friend).should == rel
    end

    it "#rel returns nil if there is no relationship" do
      a = Neography::Node.create
      b = Neography::Node.create
      a.rel(:outgoing, :friend).should be_nil
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
      n1.rel?.should be_false
      n1.outgoing(:foo) << Neography::Node.create

      n1.rel?.should be_true
      n1.rel?(:bar).should be_false
      n1.rel?(:foo).should be_true
      n1.rel?(:incoming, :foo).should be_false
      n1.rel?(:outgoing, :foo).should be_true
      n1.rel?(:foo, :incoming).should be_false
      n1.rel?(:foo, :outgoing).should be_true
      n1.rel?(:incoming).should be_false
      n1.rel?(:outgoing).should be_true
      n1.rel?(:both).should be_true
      n1.rel?(:all).should be_true
      n1.rel?.should be_true
    end
  end


  describe "delete relationship" do
    it "can delete an existing relationship" do
      p1 = Neography::Node.create
      p2 = Neography::Node.create
      new_rel = Neography::Relationship.create(:family, p1, p2)
      new_rel.del
      Neography::Relationship.load(new_rel).should be_nil
    end
  end

end