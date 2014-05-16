require 'spec_helper'

module Neography
  class Rest
    describe NodePaths do

      subject { Neography::Rest.new }

      it "gets a shortest path between two nodes" do
        expected_body = {
          "to"            => "http://localhost:7474/node/43",
          "relationships" => "relationships",
          "max_depth"     => 3,
          "algorithm"     => "shortestPath"
        }

        expect(subject.connection).to receive(:post).with("/node/42/path", json_match(:body, expected_body))

        subject.get_path("42", "43", "relationships", 3, "shortestPath")
      end

      it "gets all shortest paths between two nodes" do
        expected_body = {
          "to"            => "http://localhost:7474/node/43",
          "relationships" => "relationships",
          "max_depth"     => 3,
          "algorithm"     => "shortestPath"
        }

        expect(subject.connection).to receive(:post).with("/node/42/paths", json_match(:body, expected_body))

        subject.get_paths("42", "43", "relationships", 3, "shortestPath")
      end

      it "gets all shortest weighted paths between two nodes" do
        expected_body = {
          "to"            => "http://localhost:7474/node/43",
          "relationships" => "relationships",
          "cost_property" => "cost",
          "max_depth"     => 3,
          "algorithm"     => "shortestPath"
        }

        expect(subject.connection).to receive(:post).with("/node/42/paths", json_match(:body, expected_body))

        subject.get_shortest_weighted_path("42", "43", "relationships", "cost", 3, "shortestPath")
      end

      context "algorithm" do

        [ :shortest, "shortest", :shortestPath, "shortestPath", :short, "short" ].each do |algorithm|
          it "parses shortestPath" do
            expect(subject.send(:get_algorithm, algorithm)).to eq("shortestPath")
          end
        end

        [ :allSimplePaths, "allSimplePaths", :simple, "simple" ].each do |algorithm|
          it "parses allSimplePaths" do
            expect(subject.send(:get_algorithm, algorithm)).to eq("allSimplePaths")
          end
        end

        [ :dijkstra, "dijkstra" ].each do |algorithm|
          it "parses dijkstra" do
            expect(subject.send(:get_algorithm, algorithm)).to eq("dijkstra")
          end
        end

        it "parses allPaths by default" do
          expect(subject.send(:get_algorithm, "foo")).to eq("allPaths")
        end

      end

    end
  end
end
