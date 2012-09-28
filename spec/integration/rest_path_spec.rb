require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "get path" do
    it "can get a path between two nodes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_relationship = @neo.create_relationship("friends", new_node1, new_node2, {"since" => '10-1-2005', "met" => "college"})
      path = @neo.get_path(new_node1, new_node2, {"type"=> "friends", "direction" => "out"})
      path["start"].should == new_node1["self"]
      path["end"].should == new_node2["self"]
      path["nodes"].should == [new_node1["self"], new_node2["self"]]
    end

    it "can get the shortest path between two nodes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      @neo.create_relationship("friends", new_node3, new_node5)
      path = @neo.get_path(new_node1, new_node5, {"type"=> "friends", "direction" => "out"}, depth=3, algorithm="shortestPath")
      path["start"].should == new_node1["self"]
      path["end"].should == new_node5["self"]
      path["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node5["self"]]
    end

    it "can get the shortest weighted path between two nodes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      rel1_2 = @neo.create_relationship("friends", new_node1, new_node2)
      rel2_3 = @neo.create_relationship("friends", new_node2, new_node3)
      rel3_4 = @neo.create_relationship("friends", new_node3, new_node4)
      rel4_5 = @neo.create_relationship("friends", new_node4, new_node5)
      rel3_5 = @neo.create_relationship("friends", new_node3, new_node5)
      @neo.set_relationship_properties(rel1_2, {:weight => 1})
      @neo.set_relationship_properties(rel2_3, {:weight => 1})
      @neo.set_relationship_properties(rel3_4, {:weight => 1})
      @neo.set_relationship_properties(rel4_5, {:weight => 1})
      @neo.set_relationship_properties(rel3_5, {:weight => 3})
      path = @neo.get_shortest_weighted_path(new_node1, new_node5, {"type"=> "friends", "direction" => "out"})
      path.first["start"].should == new_node1["self"]
      path.first["end"].should == new_node5["self"]
      path.first["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"], new_node5["self"]]
    end

    it "can get a simple path between two nodes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      @neo.create_relationship("friends", new_node3, new_node5)
      path = @neo.get_path(new_node1, new_node5, {"type"=> "friends", "direction" => "out"}, depth=3, algorithm="simplePaths")
      path["start"].should == new_node1["self"]
      path["end"].should == new_node5["self"]
      path["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node5["self"]]
    end

    it "fails to get a path between two nodes 3 nodes apart when using max depth of 2" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      @neo.create_relationship("friends", new_node3, new_node5)
      expect {
        @neo.get_path(new_node1, new_node5, {"type"=> "friends", "direction" => "out"}, depth=2, algorithm="shortestPath")
      }.to raise_error Neography::NotFoundException
    end

    it "can get a path between two nodes of a specific relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("classmates", new_node1, new_node2)
      @neo.create_relationship("classmates", new_node2, new_node5)
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      path = @neo.get_path(new_node1, new_node5, {"type"=> "friends", "direction" => "out"}, depth=4, algorithm="shortestPath")
      path["start"].should == new_node1["self"]
      path["end"].should == new_node5["self"]
      path["nodes"].should == [new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"], new_node5["self"]]
    end
  end

  describe "get paths" do
    it "can get the shortest paths between two nodes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node5)
      @neo.create_relationship("friends", new_node1, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      @neo.create_relationship("friends", new_node3, new_node5)
      paths = @neo.get_paths(new_node1, new_node5, {"type"=> "friends", "direction" => "out"}, depth=4, algorithm="shortestPath")
      paths.length.should == 2
      paths[0]["length"].should == 2
      paths[0]["start"].should == new_node1["self"]
      paths[0]["end"].should == new_node5["self"]
      paths[1]["length"].should == 2
      paths[1]["start"].should == new_node1["self"]
      paths[1]["end"].should == new_node5["self"]
    end

    it "can get all paths between two nodes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node5)
      @neo.create_relationship("friends", new_node1, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      @neo.create_relationship("friends", new_node3, new_node5)
      paths = @neo.get_paths(new_node1, new_node5, {"type"=> "friends", "direction" => "out"}, depth=4, algorithm="allPaths")
      paths.length.should == 3
      paths[0]["length"].should == 2
      paths[0]["start"].should == new_node1["self"]
      paths[0]["end"].should == new_node5["self"]
      paths[1]["length"].should == 3
      paths[1]["start"].should == new_node1["self"]
      paths[1]["end"].should == new_node5["self"]
      paths[2]["length"].should == 2
      paths[2]["start"].should == new_node1["self"]
      paths[2]["end"].should == new_node5["self"]
    end

    it "can get all simple paths between two nodes" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node1)
      @neo.create_relationship("friends", new_node2, new_node5)
      @neo.create_relationship("friends", new_node1, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      @neo.create_relationship("friends", new_node3, new_node5)
      paths = @neo.get_paths(new_node1, new_node5, {"type"=> "friends", "direction" => "out"}, depth=4, algorithm="allSimplePaths")
      paths.length.should == 3
      paths[0]["length"].should == 2
      paths[0]["start"].should == new_node1["self"]
      paths[0]["end"].should == new_node5["self"]
      paths[1]["length"].should == 3
      paths[1]["start"].should == new_node1["self"]
      paths[1]["end"].should == new_node5["self"]
      paths[2]["length"].should == 2
      paths[2]["start"].should == new_node1["self"]
      paths[2]["end"].should == new_node5["self"]
    end

    it "can get paths between two nodes of max depth 2" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node5)
      @neo.create_relationship("friends", new_node1, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      @neo.create_relationship("friends", new_node3, new_node5)
      paths = @neo.get_paths(new_node1, new_node5, {"type"=> "friends", "direction" => "out"}, depth=2, algorithm="allPaths")
      paths.length.should == 2
      paths[0]["length"].should == 2
      paths[0]["start"].should == new_node1["self"]
      paths[0]["end"].should == new_node5["self"]
      paths[1]["length"].should == 2
      paths[1]["start"].should == new_node1["self"]
      paths[1]["end"].should == new_node5["self"]    end

    it "can get paths between two nodes of a specific relationship" do
      new_node1 = @neo.create_node
      new_node2 = @neo.create_node
      new_node3 = @neo.create_node
      new_node4 = @neo.create_node
      new_node5 = @neo.create_node
      @neo.create_relationship("classmates", new_node1, new_node2)
      @neo.create_relationship("classmates", new_node2, new_node5)
      @neo.create_relationship("friends", new_node1, new_node2)
      @neo.create_relationship("friends", new_node2, new_node3)
      @neo.create_relationship("friends", new_node3, new_node4)
      @neo.create_relationship("friends", new_node4, new_node5)
      @neo.create_relationship("classmates", new_node1, new_node3)
      @neo.create_relationship("classmates", new_node3, new_node5)
      paths = @neo.get_paths(new_node1, new_node5, {"type"=> "classmates", "direction" => "out"}, depth=4, algorithm="allPaths")
      paths[0]["length"].should == 2
      paths[0]["start"].should == new_node1["self"]
      paths[0]["end"].should == new_node5["self"]
      paths[1]["length"].should == 2
      paths[1]["start"].should == new_node1["self"]
      paths[1]["end"].should == new_node5["self"]    
    end

  end


end
