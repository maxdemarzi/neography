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
      expect(path["start"]).to eq(new_node1["self"])
      expect(path["end"]).to eq(new_node2["self"])
      expect(path["nodes"]).to eq([new_node1["self"], new_node2["self"]])
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
      expect(path["start"]).to eq(new_node1["self"])
      expect(path["end"]).to eq(new_node5["self"])
      expect(path["nodes"]).to eq([new_node1["self"], new_node2["self"], new_node3["self"], new_node5["self"]])
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
      expect(path.first["start"]).to eq(new_node1["self"])
      expect(path.first["end"]).to eq(new_node5["self"])
      expect(path.first["nodes"]).to eq([new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"], new_node5["self"]])
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
      expect(path["start"]).to eq(new_node1["self"])
      expect(path["end"]).to eq(new_node5["self"])
      expect(path["nodes"]).to eq([new_node1["self"], new_node2["self"], new_node3["self"], new_node5["self"]])
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
      expect(path["start"]).to eq(new_node1["self"])
      expect(path["end"]).to eq(new_node5["self"])
      expect(path["nodes"]).to eq([new_node1["self"], new_node2["self"], new_node3["self"], new_node4["self"], new_node5["self"]])
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
      expect(paths.length).to eq(2)
      expect(paths[0]["length"]).to eq(2)
      expect(paths[0]["start"]).to eq(new_node1["self"])
      expect(paths[0]["end"]).to eq(new_node5["self"])
      expect(paths[1]["length"]).to eq(2)
      expect(paths[1]["start"]).to eq(new_node1["self"])
      expect(paths[1]["end"]).to eq(new_node5["self"])
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
      expect(paths.length).to eq(3)
      expect(paths[0]["length"]).to eq(2)
      expect(paths[0]["start"]).to eq(new_node1["self"])
      expect(paths[0]["end"]).to eq(new_node5["self"])
      expect(paths[1]["length"]).to eq(3)
      expect(paths[1]["start"]).to eq(new_node1["self"])
      expect(paths[1]["end"]).to eq(new_node5["self"])
      expect(paths[2]["length"]).to eq(2)
      expect(paths[2]["start"]).to eq(new_node1["self"])
      expect(paths[2]["end"]).to eq(new_node5["self"])
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
      expect(paths.length).to eq(3)
      expect(paths[0]["length"]).to eq(2)
      expect(paths[0]["start"]).to eq(new_node1["self"])
      expect(paths[0]["end"]).to eq(new_node5["self"])
      expect(paths[1]["length"]).to eq(3)
      expect(paths[1]["start"]).to eq(new_node1["self"])
      expect(paths[1]["end"]).to eq(new_node5["self"])
      expect(paths[2]["length"]).to eq(2)
      expect(paths[2]["start"]).to eq(new_node1["self"])
      expect(paths[2]["end"]).to eq(new_node5["self"])
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
      expect(paths.length).to eq(2)
      expect(paths[0]["length"]).to eq(2)
      expect(paths[0]["start"]).to eq(new_node1["self"])
      expect(paths[0]["end"]).to eq(new_node5["self"])
      expect(paths[1]["length"]).to eq(2)
      expect(paths[1]["start"]).to eq(new_node1["self"])
      expect(paths[1]["end"]).to eq(new_node5["self"])    end

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
      expect(paths[0]["length"]).to eq(2)
      expect(paths[0]["start"]).to eq(new_node1["self"])
      expect(paths[0]["end"]).to eq(new_node5["self"])
      expect(paths[1]["length"]).to eq(2)
      expect(paths[1]["start"]).to eq(new_node1["self"])
      expect(paths[1]["end"]).to eq(new_node5["self"])    
    end

  end


end
