require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Relationship do
  describe "create relationship" do
    it "#new(:family, p1, p2) creates a new relationship between to nodes of given type" do
      p1 = Neography::Node.create
      p2 = Neography::Node.create

      new_rel = Neography::Relationship.create(:family, p1, p2)
      puts new_rel.inspect
      new_rel.start_node.should == p1
      new_rel.end_node.should == p2


#      p1.outgoing(:family).should include(p2)
#      p2.incoming(:family).should include(p1)
    end

    it "#new(:family, p1, p2, :since => '1998', :colour => 'blue') creates relationship and sets its properties" do
      p1 = Neography::Node.create
      p2 = Neography::Node.create
 
      rel = Neography::Relationship.create(:family, p1, p2, :since => 1998, :colour => 'blue')
      rel[:since].should == 1998
      rel[:colour].should == 'blue'
      rel.since.should == 1998
      rel.colourshould == 'blue'
    end

    it "#outgoing(:friends).create(other) creates a new relationship between self and other node" do
      p1 = Neography::Node.create
      p2 = Neography::Node.create

      rel = p1.outgoing(:foo).create(p2)
      p1.outgoing(:foo).first.should == p2
      rel.should be_kind_of(Neography::Relationship)
    end
  end

  describe "rel?" do
    it "#rel? returns true if there are any relationships" do
      n1 = Neography::Node.create
      n2 = Neography::Node.create
      new_rel = Neography::Relationship.create(:foo, n1, n2)
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