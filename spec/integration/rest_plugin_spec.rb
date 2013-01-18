require 'spec_helper'

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
      existing_node = @neo.execute_script("g.v(id)", {:id => id.to_i})
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

    it "can get the a node" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_query("start n=node(#{id}) return n")
      existing_node.should_not be_nil
      existing_node.should have_key("data")
      existing_node.should have_key("columns")
      existing_node["data"][0][0].should have_key("self")
      existing_node["data"][0][0]["self"].split('/').last.should == id
    end

    it "can get the a node with a variable" do
      new_node = @neo.create_node
      id = new_node["self"].split('/').last
      existing_node = @neo.execute_query("start n=node({id}) return n", {:id => id.to_i})
      existing_node.should_not be_nil
      existing_node.should have_key("data")
      existing_node.should have_key("columns")
      existing_node["data"][0][0].should have_key("self")
      existing_node["data"][0][0]["self"].split('/').last.should == id
    end

    it "can delete everything but start node" do
      @neo.execute_query("START n=node(*) MATCH n-[r?]-() WHERE ID(n) <> 0 DELETE n,r")
      expect {
        @neo.execute_query("start n=node({id}) return n", {:id => 1})
      }.to raise_error(Neography::BadInputException)
      root_node = @neo.execute_query("start n=node({id}) return n", {:id => 0})
      root_node.should_not be_nil
    end

    it "throws an error for an invalid query" do
      expect {
        @neo.execute_query("this is not a query")
      }.to raise_error(Neography::SyntaxException)
    end

    it "throws an error for not unique paths in unique path creation" do
      node1 = @neo.create_node
      node2 = @neo.create_node

      id1 = node1["self"].split('/').last.to_i
      id2 = node2["self"].split('/').last.to_i

      # create two 'FOO' relationships
      @neo.execute_query("START a=node({id1}), b=node({id2}) CREATE a-[r:FOO]->b RETURN r", { :id1 => id1, :id2 => id2 })
      @neo.execute_query("START a=node({id1}), b=node({id2}) CREATE a-[r:FOO]->b RETURN r", { :id1 => id1, :id2 => id2 })

      expect {
        @neo.execute_query("START a=node({id1}), b=node({id2}) CREATE UNIQUE a-[r:FOO]->b RETURN r", { :id1 => id1, :id2 => id2 })
      }.to raise_error(Neography::UniquePathNotUniqueException)
    end

  end

end
