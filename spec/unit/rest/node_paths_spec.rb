require 'spec_helper'

module Neography
  class Rest
    describe NodePaths do

      let(:connection) { stub(:configuration => "http://configuration") }
      subject { NodePaths.new(connection) }

      it "gets a shortest path between two nodes" do
        expected_body = {
          "to"            => "http://configuration/node/43",
          "relationships" => "relationships",
          "max_depth"     => 3,
          "algorithm"     => "shortestPath"
        }

        connection.should_receive(:post).with("/node/42/path", json_match(:body, expected_body))

        subject.get("42", "43", "relationships", 3, "shortestPath")
      end

      it "gets all shortest paths between two nodes" do
        expected_body = {
          "to"            => "http://configuration/node/43",
          "relationships" => "relationships",
          "max_depth"     => 3,
          "algorithm"     => "shortestPath"
        }

        connection.should_receive(:post).with("/node/42/paths", json_match(:body, expected_body))

        subject.get_all("42", "43", "relationships", 3, "shortestPath")
      end

      it "gets all shortest weighted paths between two nodes" do
        expected_body = {
          "to"            => "http://configuration/node/43",
          "relationships" => "relationships",
          "cost_property" => "cost",
          "max_depth"     => 3,
          "algorithm"     => "shortestPath"
        }

        connection.should_receive(:post).with("/node/42/paths", json_match(:body, expected_body))

        subject.shortest_weighted("42", "43", "relationships", "cost", 3, "shortestPath")
      end

      context "algorithm" do

        subject { NodePaths.new(nil) }

        [ :shortest, "shortest", :shortestPath, "shortestPath", :short, "short" ].each do |algorithm|
          it "parses shortestPath" do
            subject.send(:get_algorithm, algorithm).should == "shortestPath"
          end
        end

        [ :allSimplePaths, "allSimplePaths", :simple, "simple" ].each do |algorithm|
          it "parses allSimplePaths" do
            subject.send(:get_algorithm, algorithm).should == "allSimplePaths"
          end
        end

        [ :dijkstra, "dijkstra" ].each do |algorithm|
          it "parses dijkstra" do
            subject.send(:get_algorithm, algorithm).should == "dijkstra"
          end
        end

        it "parses allPaths by default" do
          subject.send(:get_algorithm, "foo").should == "allPaths"
        end

      end

    end
  end
end
