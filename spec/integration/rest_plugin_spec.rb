require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "execute gremlin script" do
    it "can get the root node id" do
      root_node = @neo.execute_script("g.v(0)")
      root_node.should have_key("self")
      root_node["self"].split('/').last.should == "0"
    end

    it "can get the a node" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_script("g.v(#{id})")
      existing_node.should_not be_nil
      existing_node.should have_key("self")
      existing_node["self"].split('/').last.should == id
    end

    it "can get the a node with a variable" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_script("g.v(id)", {:id => id})
      existing_node.should_not be_nil
      existing_node.should have_key("self")
      existing_node["self"].split('/').last.should == id
    end



  end

  describe "execute cypher query" do
    it "can get the root node id" do
      root_node = @neo.execute_query("start n=node(0) return n")
      root_node.should have_key("data")
      root_node.should have_key("columns")
      root_node["data"][0][0].should have_key("self")
      root_node["data"][0][0]["self"].split('/').last.should == "0"
    end
  end

end