require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "can create many nodes threaded" do
    it "can create empty nodes threaded" do
      new_nodes = @neo.create_nodes_threaded(2)
      new_nodes.should_not be_nil
      new_nodes.size.should == 2
    end

    it "is faster than non-threaded?" , :slow => true do
      Benchmark.bm do |x|
        x.report("create 500 nodes         ") { @not_threaded = @neo.create_nodes(500) }
        x.report("create 500 nodes threaded") { @threaded     = @neo.create_nodes_threaded(500) }
        x.report("create 1000 nodes threaded") { @threaded2c   = @neo.create_nodes_threaded(1000) }
      end

      @not_threaded[99].should_not be_nil
      @threaded[99].should_not be_nil
      @threaded2c[199].should_not be_nil
    end

  end

  describe "can create many nodes" do
    it "can create empty nodes" do
      new_nodes = @neo.create_nodes(2)
      new_nodes.should_not be_nil
      new_nodes.size.should == 2
    end

    it "can create nodes with one property" do
      new_nodes = @neo.create_nodes([{"name" => "Max"}, {"name" => "Alex"}])
      new_nodes[0]["data"]["name"].should == "Max"
      new_nodes[1]["data"]["name"].should == "Alex"
    end

    it "can create nodes with one property that are different" do
      new_nodes = @neo.create_nodes([{"name" => "Max"}, {"age" => 24}])
      new_nodes[0]["data"]["name"].should == "Max"
      new_nodes[1]["data"]["age"].should == 24
    end

    it "can create nodes with more than one property" do
      new_nodes = @neo.create_nodes([{"age" => 31, "name" => "Max"}, {"age" => 24, "name" => "Alex"}])
      new_nodes[0]["data"]["name"].should == "Max"
      new_nodes[0]["data"]["age"].should == 31
      new_nodes[1]["data"]["name"].should == "Alex"
      new_nodes[1]["data"]["age"].should == 24
    end

    it "can create nodes with more than one property that are different" do
      new_nodes = @neo.create_nodes([{"age" => 31, "name" => "Max"}, {"height" => "5-11", "weight" => 215}])
      new_nodes[0]["data"]["name"].should == "Max"
      new_nodes[0]["data"]["age"].should == 31
      new_nodes[1]["data"]["height"].should == "5-11"
      new_nodes[1]["data"]["weight"].should == 215
    end

    it "is not super slow?" , :slow => true do
      Benchmark.bm do |x|
        x.report(  "create 1 node" ) { @neo.create_nodes(  1) }
        x.report( "create 10 nodes") { @neo.create_nodes( 10) }
        x.report("create 100 nodes") { @neo.create_nodes(100) }
      end
    end
  end

  describe "can get many nodes" do
    it "can get 2 nodes passed in as an array" do
      new_nodes = @neo.create_nodes(2)
      existing_nodes = @neo.get_nodes(new_nodes)
      existing_nodes.should_not be_nil
      existing_nodes.size.should == 2
    end

    it "can get 2 nodes passed in by commas" do
      new_nodes = @neo.create_nodes(2)
      new_node1 = new_nodes[0]["self"].split('/').last
      new_node2 = new_nodes[1]["self"].split('/').last
      existing_nodes = @neo.get_nodes(new_node1, new_node2)
      existing_nodes.should_not be_nil
      existing_nodes.size.should == 2
      existing_nodes[0]["self"] == new_node1["self"]
      existing_nodes[1]["self"] == new_node2["self"]
    end

    it "is not super slow?" , :slow => true do
               one_node  = @neo.create_nodes(  1)
              ten_nodes =  @neo.create_nodes( 10)
      one_hundred_nodes =  @neo.create_nodes(100)

      Benchmark.bm do |x|
        x.report(  "get 1 node ") { @neo.get_nodes(one_node) }
        x.report( "get 10 nodes") { @neo.get_nodes(ten_nodes) }
        x.report("get 100 nodes") { @neo.get_nodes(one_hundred_nodes) }
      end
    end

  end

end
