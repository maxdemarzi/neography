require 'spec_helper'

module Neography
  class Rest
    describe Nodes do

      subject { Neography::Rest.new }

      context "get nodes" do
        it "gets single nodes" do
          subject.connection.should_receive(:get).with("/node/42")
          subject.get_node("42")
        end

        it "gets multiple nodes" do
          subject.connection.should_receive(:get).with("/node/42")
          subject.connection.should_receive(:get).with("/node/43")
          subject.get_nodes("42", "43")
        end

        it "returns multiple nodes in an array" do
          subject.connection.stub(:get).and_return("foo", "bar")
          subject.get_nodes("42", "43").should == [ "foo", "bar" ]
        end

        it "gets the root node" do
          subject.connection.stub(:get).with("/").and_return({ "reference_node" => "42" })
          subject.connection.should_receive(:get).with("/node/42")
          subject.get_root
        end

        it "returns the root node" do
          subject.connection.stub(:get).and_return({ "reference_node" => "42" }, "foo")
          subject.get_root.should == "foo"
        end
      end

      context "create nodes" do

        it "creates with attributes" do
          options = {
            :body    => '{"foo":"bar","baz":"qux"}',
            :headers => json_content_type
          }
          subject.connection.should_receive(:post).with("/node", options)
          subject.create_node_with_attributes({:foo => "bar", :baz => "qux"})
        end

        it "returns the created node" do
          subject.connection.stub(:post).and_return("foo")
          subject.create_node_with_attributes({}).should == "foo"
        end

        it "creates with attributes using #create method" do
          options = {
            :body    => '{"foo":"bar","baz":"qux"}',
            :headers => json_content_type
          }
          subject.connection.should_receive(:post).with("/node", options)
          subject.create_node({:foo => "bar", :baz => "qux"})
        end

        it "creates empty nodes" do
          subject.connection.should_receive(:post).with("/node")
          subject.create_empty_node
        end

        it "returns an empty node" do
          subject.connection.stub(:post).and_return("foo")
          subject.create_empty_node.should == "foo"
        end

        it "creates empty nodes using #create method" do
          subject.connection.should_receive(:post).with("/node")
          subject.create_node
        end

      end

      context "delete nodes" do

        it "deletes a node" do
          subject.connection.should_receive(:delete).with("/node/42")
          subject.delete_node("42")
        end

      end

      context "#create_multiple" do

        it "creates multiple with attributes" do
          options1 = {
            :body    => '{"foo1":"bar1","baz1":"qux1"}',
            :headers => json_content_type
          }
          options2 = {
            :body    => '{"foo2":"bar2","baz2":"qux2"}',
            :headers => json_content_type
          }
          subject.connection.should_receive(:post).with("/node", options1)
          subject.connection.should_receive(:post).with("/node", options2)

          subject.create_nodes([
            {:foo1 => "bar1", :baz1 => "qux1"},
            {:foo2 => "bar2", :baz2 => "qux2"}
          ])
        end

        it "returns multiple nodes with attributes in an array" do
          subject.connection.stub(:post).and_return("foo", "bar")
          subject.create_nodes([{},{}]).should == ["foo", "bar"]
        end

        # exotic?
        it "creates multiple with and without attributes" do
          options1 = {
            :body    => '{"foo1":"bar1","baz1":"qux1"}',
            :headers => json_content_type
          }
          subject.connection.should_receive(:post).with("/node", options1)
          subject.connection.should_receive(:post).with("/node")

          subject.create_nodes([
            {:foo1 => "bar1", :baz1 => "qux1"},
            "not a hash" # ?
          ])
        end

        it "creates multiple empty nodes" do
          subject.connection.should_receive(:post).with("/node").twice
          subject.create_nodes(2)
        end

        it "returns multiple empty nodes in an array" do
          subject.connection.stub(:post).and_return("foo", "bar")
          subject.create_nodes(2).should == ["foo", "bar"]
        end

      end

      context "#create_multiple_threaded" do

        let(:connection) { double(:max_threads => 2) }

        it "creates multiple with attributes" do
          options1 = {
            :body    => '{"foo1":"bar1","baz1":"qux1"}',
            :headers => json_content_type
          }
          options2 = {
            :body    => '{"foo2":"bar2","baz2":"qux2"}',
            :headers => json_content_type
          }
          subject.connection.should_receive(:post).with("/node", options1)
          subject.connection.should_receive(:post).with("/node", options2)

          subject.create_nodes_threaded([
            {:foo1 => "bar1", :baz1 => "qux1"},
            {:foo2 => "bar2", :baz2 => "qux2"}
          ])
        end

        # exotic?
        it "creates multiple with and without attributes" do
          options1 = {
            :body    => '{"foo1":"bar1","baz1":"qux1"}',
            :headers => json_content_type
          }
          subject.connection.should_receive(:post).with("/node", options1)
          subject.connection.should_receive(:post).with("/node")

          subject.create_nodes_threaded([
            {:foo1 => "bar1", :baz1 => "qux1"},
            "not a hash" # ?
          ])
        end

        it "creates multiple empty nodes" do
          subject.connection.should_receive(:post).with("/node").twice
          subject.create_nodes_threaded(2)
        end

      end

    end
  end
end
