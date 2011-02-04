require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new({:server => '4c36b641.neo4j.atns.de', :port => 7474, :directory => '/9dc1fda5be8b5cde29621e21cae5adece3de0f37', :authentication => 'basic', :username => "abbe3c012", :password => "34d7b22eb"})
  end

  describe "get_root" do
    it "can get the root node" do
      root_node = @neo.get_root
      root_node.should have_key("reference_node")
    end
  end

  describe "create_node" do
    it "can create an empty node" do
      new_node = @neo.create_node
      new_node.should_not be_nil
    end
  end
end