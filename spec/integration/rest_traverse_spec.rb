require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "traverse" do
    it "can traverse the graph and return nodes" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = @neo.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = @neo.create_node
      new_node4[:id] = new_node4["self"].split('/').last
      new_node5 = @neo.create_node
      new_node5[:id] = new_node5["self"].split('/').last
      @neo.create_relationship("friends", new_node1[:id], new_node2[:id])
      @neo.create_relationship("friends", new_node2[:id], new_node3[:id])
      @neo.create_relationship("friends", new_node3[:id], new_node4[:id])
      @neo.create_relationship("friends", new_node4[:id], new_node5[:id])
      @neo.create_relationship("friends", new_node3[:id], new_node5[:id])
      nodes = @neo.traverse(new_node1[:id], "nodes", {"relationships" => {"type"=> "friends", "direction" => "out"}, "depth" => 4} )
      nodes.should_not be_nil
      nodes[0]["self"].should == new_node2["self"]
      nodes[1]["self"].should == new_node3["self"]
      nodes[2]["self"].should == new_node4["self"]
      nodes[3]["self"].should == new_node5["self"]
    end

    it "can traverse the graph and return relationships" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = @neo.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = @neo.create_node
      new_node4[:id] = new_node4["self"].split('/').last
      new_node5 = @neo.create_node
      new_node5[:id] = new_node5["self"].split('/').last

      new_relationship1= @neo.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship2= @neo.create_relationship("friends", new_node2[:id], new_node3[:id])
      new_relationship3= @neo.create_relationship("friends", new_node3[:id], new_node4[:id])
      new_relationship4= @neo.create_relationship("friends", new_node4[:id], new_node5[:id])
      new_relationship5= @neo.create_relationship("friends", new_node3[:id], new_node5[:id])

      relationships = @neo.traverse(new_node1[:id], "relationships", {"relationships" => {"type"=> "friends", "direction" => "out"}, "depth" => 4} )
      relationships.should_not be_nil

      relationships[0]["self"].should == new_relationship1["self"]
      relationships[1]["self"].should == new_relationship2["self"]
      relationships[2]["self"].should == new_relationship3["self"]
      relationships[3]["self"].should == new_relationship4["self"]
    end

    it "can traverse the graph and return paths" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = @neo.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = @neo.create_node
      new_node4[:id] = new_node4["self"].split('/').last
      new_node5 = @neo.create_node
      new_node5[:id] = new_node5["self"].split('/').last

      new_relationship1= @neo.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship2= @neo.create_relationship("friends", new_node2[:id], new_node3[:id])
      new_relationship3= @neo.create_relationship("friends", new_node3[:id], new_node4[:id])
      new_relationship4= @neo.create_relationship("friends", new_node4[:id], new_node5[:id])
      new_relationship5= @neo.create_relationship("friends", new_node3[:id], new_node5[:id])

      paths = @neo.traverse(new_node1[:id], "paths", {"relationships" => {"type"=> "friends", "direction" => "out"}, "depth" => 4} )
      paths.should_not be_nil
  
      paths[0]["nodes"].should == [new_node1["self"], new_node2["self"]]
      paths[1]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"]]
      paths[2]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"]]
      paths[3]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"], new_node5["self"]]
    end

    it "can traverse the graph up to a certain depth" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = @neo.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = @neo.create_node
      new_node4[:id] = new_node4["self"].split('/').last
      new_node5 = @neo.create_node
      new_node5[:id] = new_node5["self"].split('/').last

      new_relationship1= @neo.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship2= @neo.create_relationship("friends", new_node2[:id], new_node3[:id])
      new_relationship3= @neo.create_relationship("friends", new_node3[:id], new_node4[:id])
      new_relationship4= @neo.create_relationship("friends", new_node4[:id], new_node5[:id])
      new_relationship5= @neo.create_relationship("friends", new_node3[:id], new_node5[:id])

      paths = @neo.traverse(new_node1[:id], "paths", {"relationships" => {"type"=> "friends", "direction" => "out"}, "depth" => 3} )
      paths.should_not be_nil

      paths[0]["nodes"].should == [new_node1["self"], new_node2["self"]]
      paths[1]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"]]
      paths[2]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"]]
      paths[3]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node5["self"]]
    end

    it "can traverse the graph in a certain order" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = @neo.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = @neo.create_node
      new_node4[:id] = new_node4["self"].split('/').last
      new_node5 = @neo.create_node
      new_node5[:id] = new_node5["self"].split('/').last

      new_relationship1= @neo.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship2= @neo.create_relationship("friends", new_node2[:id], new_node3[:id])
      new_relationship3= @neo.create_relationship("friends", new_node3[:id], new_node4[:id])
      new_relationship4= @neo.create_relationship("friends", new_node4[:id], new_node5[:id])
      new_relationship5= @neo.create_relationship("friends", new_node3[:id], new_node5[:id])

      paths = @neo.traverse(new_node1[:id], "paths", {"order" => "breadth first", "relationships" => {"type"=> "friends", "direction" => "out"}, "depth" => 4} )
      paths.should_not be_nil
    
      paths[0]["nodes"].should == [new_node1["self"], new_node2["self"]]
      paths[1]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"]]
      paths[2]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"]]
      paths[3]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node5["self"]]
    end

    it "can traverse the graph with a specific uniqueness" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = @neo.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = @neo.create_node
      new_node4[:id] = new_node4["self"].split('/').last
      new_node5 = @neo.create_node
      new_node5[:id] = new_node5["self"].split('/').last

      new_relationship1= @neo.create_relationship("roommates", new_node1[:id], new_node2[:id])
      new_relationship2= @neo.create_relationship("roommates", new_node2[:id], new_node3[:id])
      new_relationship1= @neo.create_relationship("friends", new_node3[:id], new_node2[:id])
      new_relationship2= @neo.create_relationship("friends", new_node2[:id], new_node5[:id])
      new_relationship3= @neo.create_relationship("friends", new_node3[:id], new_node4[:id])
      new_relationship4= @neo.create_relationship("friends", new_node4[:id], new_node5[:id])
      new_relationship5= @neo.create_relationship("friends", new_node3[:id], new_node5[:id])

      paths = @neo.traverse(new_node1[:id], "paths", {"order" => "breadth first", "uniqueness" => "node global", "relationships" => [{"type"=> "roommates", "direction" => "all"},{"type"=> "friends", "direction" => "out"}], "depth" => 4} )
      paths.should_not be_nil
    
      paths[0]["nodes"].should == [new_node1["self"], new_node2["self"]]
      paths[1]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"]]
      paths[2]["nodes"].should == [new_node1["self"], new_node2["self"], new_node5["self"]]
      paths[3]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"]]
    end

    it "can traverse the graph with a prune evaluator" do
      new_node1 = @neo.create_node("age" => 31, "name" => "Max")
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node("age" => 30, "name" => "Helene")
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = @neo.create_node("age" => 17, "name" => "Alex")
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = @neo.create_node("age" => 24, "name" => "Eric")
      new_node4[:id] = new_node4["self"].split('/').last
      new_node5 = @neo.create_node("age" => 32, "name" => "Leslie")
      new_node5[:id] = new_node5["self"].split('/').last

      new_relationship1= @neo.create_relationship("friends", new_node1[:id], new_node2[:id])
      new_relationship2= @neo.create_relationship("friends", new_node2[:id], new_node3[:id])
      new_relationship3= @neo.create_relationship("friends", new_node3[:id], new_node4[:id])
      new_relationship4= @neo.create_relationship("friends", new_node4[:id], new_node5[:id])
      new_relationship5= @neo.create_relationship("friends", new_node3[:id], new_node5[:id])

      paths = @neo.traverse(new_node1[:id],
                            "paths",
                            {"relationships" => {"type"=> "friends", "direction" => "out"}, 
                             "depth" => 3,
                             "prune evaluator" => {"language" => "javascript",  "body" => "position.endNode().getProperty('age') < 21;"
                              }} )
      paths.should_not be_nil
      paths[0]["nodes"].should == [new_node1["self"], new_node2["self"]]
      paths[1]["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"]]
      paths[2].should be_nil
    end

    it "can traverse the graph with a return filter" do
      new_node1 = @neo.create_node
      new_node1[:id] = new_node1["self"].split('/').last
      new_node2 = @neo.create_node
      new_node2[:id] = new_node2["self"].split('/').last
      new_node3 = @neo.create_node
      new_node3[:id] = new_node3["self"].split('/').last
      new_node4 = @neo.create_node
      new_node4[:id] = new_node4["self"].split('/').last
      new_node5 = @neo.create_node
      new_node5[:id] = new_node5["self"].split('/').last
      @neo.create_relationship("friends", new_node1[:id], new_node2[:id])
      @neo.create_relationship("friends", new_node2[:id], new_node3[:id])
      @neo.create_relationship("friends", new_node3[:id], new_node4[:id])
      @neo.create_relationship("friends", new_node4[:id], new_node5[:id])
      @neo.create_relationship("friends", new_node3[:id], new_node5[:id])
      nodes = @neo.traverse(new_node1[:id], "nodes", {"relationships" => {"type"=> "friends", "direction" => "out"}, 
                                                      "return filter" => {"language" => "builtin", "name" => "all"},
                                                      "depth" => 4} )
      nodes.should_not be_nil
      nodes[0]["self"].should == new_node1["self"]
      nodes[1]["self"].should == new_node2["self"]
      nodes[2]["self"].should == new_node3["self"]
      nodes[3]["self"].should == new_node4["self"]
      nodes[4]["self"].should == new_node5["self"]
    end


  end

end