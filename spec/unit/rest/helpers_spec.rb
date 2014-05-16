require 'spec_helper'

module Neography
  class Rest
    describe Helpers do

      subject { Neography::Rest.new }

      context "directions" do

        [ :incoming, "incoming", :in, "in" ].each do |direction|
          it "parses 'in' direction" do
            expect(subject.parse_direction(direction)).to eq("in")
          end
        end

        [ :outgoing, "outgoing", :out, "out" ].each do |direction|
          it "parses 'out' direction" do
            expect(subject.parse_direction(direction)).to eq("out")
          end
        end

        it "parses 'all' direction by default" do
          expect(subject.parse_direction("foo")).to eq("all")
        end

      end
      
context "options" do
        let(:traversal) { NodeTraversal.new(nil) }

        context "order" do
          [ :breadth, "breadth", "breadth first", "breadthFirst", :wide, "wide" ].each do |order|
            it "parses breadth first" do
              expect(subject.send(:parse_order, order)).to eq("breadth first")
            end
          end

          it "parses depth first by default" do
            expect(subject.send(:parse_order, "foo")).to eq("depth first")
          end
        end

        context "uniqueness" do
          [ :nodeglobal, "node global", "nodeglobal", "node_global" ].each do |order|
            it "parses node global" do
              expect(subject.send(:parse_uniqueness, order)).to eq("node global")
            end
          end

          [ :nodepath, "node path", "nodepath", "node_path" ].each do |order|
            it "parses node path" do
              expect(subject.send(:parse_uniqueness, order)).to eq("node path")
            end
          end

          [ :noderecent, "node recent", "noderecent", "node_recent" ].each do |order|
            it "parses node recent" do
              expect(subject.send(:parse_uniqueness, order)).to eq("node recent")
            end
          end

          [ :relationshipglobal, "relationship global", "relationshipglobal", "relationship_global" ].each do |order|
            it "parses relationship global" do
              expect(subject.send(:parse_uniqueness, order)).to eq("relationship global")
            end
          end

          [ :relationshippath, "relationship path", "relationshippath", "relationship_path" ].each do |order|
            it "parses relationship path" do
              expect(subject.send(:parse_uniqueness, order)).to eq("relationship path")
            end
          end

          [ :relationshiprecent, "relationship recent", "relationshiprecent", "relationship_recent" ].each do |order|
            it "parses relationship recent" do
              expect(subject.send(:parse_uniqueness, order)).to eq("relationship recent")
            end
          end

          it "parses none by default" do
            expect(subject.send(:parse_uniqueness, "foo")).to eq("none")
          end
        end

        context "depth" do
          it "parses nil as nil" do
            expect(subject.send(:parse_depth, nil)).to be_nil
          end
          it "parses 0 as 1" do
            expect(subject.send(:parse_depth, "0")).to eq(1)
          end
          it "parses integers" do
            expect(subject.send(:parse_depth, "42")).to eq(42)
          end
        end

        context "type" do
          [ :relationship, "relationship", :relationships, "relationships" ].each do |type|
            it "parses relationship" do
              expect(subject.send(:parse_type, type)).to eq("relationship")
            end
          end
          [ :path, "path", :paths, "paths" ].each do |type|
            it "parses path" do
              expect(subject.send(:parse_type, type)).to eq("path")
            end
          end
          [ :fullpath, "fullpath", :fullpaths, "fullpaths" ].each do |type|
            it "parses fullpath" do
              expect(subject.send(:parse_type, type)).to eq("fullpath")
            end
          end

          it "parses node by default" do
            expect(subject.send(:parse_type, "foo")).to eq("node")
          end
        end
      end      


    end
  end
end
