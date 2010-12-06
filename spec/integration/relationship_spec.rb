require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Relationship do
  it "#new(:family, p1, p2) creates a new relationship between to nodes of given type" do
    p1 = Neography::Node.create
    p2 = Neography::Node.create

    new_rel = Neography::Relationship.create(:family, p1, p2)
    puts new_rel.inspect
    new_rel.start_node.should == p1
    new_rel.end_node.should == p2
#    p1.outgoing(:family).should include(p2)
#    p2.incoming(:family).should include(p1)
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

  it "#outgoing(:friends).new(other) creates a new relationship between self and other node" do
    p1 = Neography::Node.create
    p2 = Neography::Node.create

    rel = p1.outgoing(:foo).create(p2)
    p1.outgoing(:foo).first.should == p2
    rel.should be_kind_of(Neography::Relationship)
  end

end