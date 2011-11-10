require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Relationship, "find" do
  before(:each) do
    pending "Phase 2 - Index part is not done."
    Neography::Relationship.index(:strength)
  end

  it "can index when Neography::Relationships are created" do
    a            = Neography::Node.create
    b            = Neography::Node.create
    r            = Neography::Relationship.create(:friends, a, b)
    r[:strength] = 'strong'
    Neography::Relationship.find('strength: strong').first.should == r
  end

  it "can remove index when Neography::Relationship is deleted, just like nodes" do
    a            = Neography::Node.create
    b            = Neography::Node.create
    r            = Neography::Relationship.create(:friends, a, b)
    r[:strength] = 'weak'
    r2           = Neography::Relationship.find('strength: weak').first
    r2.should == r
    r2.del
    Neography::Relationship.find('strength: weak').should be_empty
  end
end


describe Neography::Node, "find" do

end
