require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Relationship do
  it "can create an empty relationship" do
    Neography::Relationship.new(:friends, Neography::Node.new, Neography::Node.new).should include(:rel_id)
  end

  it "can create a relationship with one property" do
    Neography::Relationship.new(:friends, Neography::Node.new, Neography::Node.new, {:since => '10-1-2010'}).should include("since")
  end

  it "can create a relationship with multiple properties" do
    Neography::Relationship.new(:friends, Neography::Node.new, Neography::Node.new, {:since => '10-1-2010', :closeness => 'bff'}).should include("closeness"=>"bff", "since"=>"10-1-2010")
  end

  it "can get a relationship's properties" do
    rel = Neography::Relationship.new(:friends, Neography::Node.new, Neography::Node.new)
    Neography::Relationship.set_properties(rel[:rel_id], {:since => '10-1-2010'} ).should be_nil
    Neography::Relationship.properties(rel[:rel_id]).should include("since"=>"10-1-2010")
  end

  it "returns nil if a relationship has no properties" do
    rel = Neography::Relationship.new(:friends, Neography::Node.new, Neography::Node.new)
    Neography::Relationship.properties(rel[:rel_id]).should be_nil
  end

end