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
      [*b.outgoing].size.should == 3
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

      [*b.both].size.should == 4 
      b.incoming.should include(a)
      b.outgoing.should include(c)
    end

  end

#      b.both.each { |n| puts n.inspect }


  describe "rels" do
    it "" do
      pending
    end
  end

  describe "rel" do
    it "" do
      pending
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