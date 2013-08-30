require 'spec_helper'

module Neography
  class Rest
    describe NodeTraversal do

      let(:connection) { double }
      subject { NodeTraversal.new(connection) }

      it "traverses" do
        description = {
          "order"           => :breadth,
          "uniqueness"      => :nodeglobal,
          "relationships"   => "relationships",
          "prune evaluator" => "prune_evaluator",
          "return filter"   => "return_filter",
          "depth"           => 4
        }

        expected_body = {
          "order"           => "breadth first",
          "uniqueness"      => "node global",
          "relationships"   => "relationships",
          "prune_evaluator" => "prune_evaluator",
          "return_filter"   => "return_filter",
          "max_depth"       => 4
        }

        connection.should_receive(:post).with("/node/42/traverse/relationship", json_match(:body, expected_body))

        subject.traverse("42", :relationship, description)
      end

      context "options" do
        let(:traversal) { NodeTraversal.new(nil) }

        context "order" do
          [ :breadth, "breadth", "breadth first", "breadthFirst", :wide, "wide" ].each do |order|
            it "parses breadth first" do
              subject.send(:get_order, order).should == "breadth first"
            end
          end

          it "parses depth first by default" do
            subject.send(:get_order, "foo").should == "depth first"
          end
        end

        context "uniqueness" do
          [ :nodeglobal, "node global", "nodeglobal", "node_global" ].each do |order|
            it "parses node global" do
              subject.send(:get_uniqueness, order).should == "node global"
            end
          end

          [ :nodepath, "node path", "nodepath", "node_path" ].each do |order|
            it "parses node path" do
              subject.send(:get_uniqueness, order).should == "node path"
            end
          end

          [ :noderecent, "node recent", "noderecent", "node_recent" ].each do |order|
            it "parses node recent" do
              subject.send(:get_uniqueness, order).should == "node recent"
            end
          end

          [ :relationshipglobal, "relationship global", "relationshipglobal", "relationship_global" ].each do |order|
            it "parses relationship global" do
              subject.send(:get_uniqueness, order).should == "relationship global"
            end
          end

          [ :relationshippath, "relationship path", "relationshippath", "relationship_path" ].each do |order|
            it "parses relationship path" do
              subject.send(:get_uniqueness, order).should == "relationship path"
            end
          end

          [ :relationshiprecent, "relationship recent", "relationshiprecent", "relationship_recent" ].each do |order|
            it "parses relationship recent" do
              subject.send(:get_uniqueness, order).should == "relationship recent"
            end
          end

          it "parses none by default" do
            subject.send(:get_uniqueness, "foo").should == "none"
          end
        end

        context "depth" do
          it "parses nil as nil" do
            subject.send(:get_depth, nil).should be_nil
          end
          it "parses 0 as 1" do
            subject.send(:get_depth, "0").should == 1
          end
          it "parses integers" do
            subject.send(:get_depth, "42").should == 42
          end
        end

        context "type" do
          [ :relationship, "relationship", :relationships, "relationships" ].each do |type|
            it "parses relationship" do
              subject.send(:get_type, type).should == "relationship"
            end
          end
          [ :path, "path", :paths, "paths" ].each do |type|
            it "parses path" do
              subject.send(:get_type, type).should == "path"
            end
          end
          [ :fullpath, "fullpath", :fullpaths, "fullpaths" ].each do |type|
            it "parses fullpath" do
              subject.send(:get_type, type).should == "fullpath"
            end
          end

          it "parses node by default" do
            subject.send(:get_type, "foo").should == "node"
          end
        end
      end

    end
  end
end
