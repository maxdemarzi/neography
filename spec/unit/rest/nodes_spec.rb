require 'spec_helper'

module Neography
  class Rest
    describe Nodes do

      let(:connection) { double }
      subject { Nodes.new(connection) }

      context "get nodes" do
        it "gets single nodes" do
          connection.should_receive(:get).with("/node/42")
          subject.get("42")
        end

        it "gets multiple nodes" do
          connection.should_receive(:get).with("/node/42")
          connection.should_receive(:get).with("/node/43")
          subject.get_each("42", "43")
        end

        it "returns multiple nodes in an array" do
          connection.stub(:get).and_return("foo", "bar")
          subject.get_each("42", "43").should == [ "foo", "bar" ]
        end

        it "gets the root node" do
          connection.stub(:get).with("/").and_return({ "reference_node" => "42" })
          connection.should_receive(:get).with("/node/42")
          subject.root
        end

        it "returns the root node" do
          connection.stub(:get).and_return({ "reference_node" => "42" }, "foo")
          subject.root.should == "foo"
        end
      end

      context "create nodes" do

        it "creates with attributes" do
          options = {
            :body    => '{"foo":"bar","baz":"qux"}',
            :headers => json_content_type
          }
          connection.should_receive(:post).with("/node", options)
          subject.create_with_attributes({:foo => "bar", :baz => "qux"})
        end

        it "returns the created node" do
          connection.stub(:post).and_return("foo")
          subject.create_with_attributes({}).should == "foo"
        end

        it "creates with attributes using #create method" do
          options = {
            :body    => '{"foo":"bar","baz":"qux"}',
            :headers => json_content_type
          }
          connection.should_receive(:post).with("/node", options)
          subject.create({:foo => "bar", :baz => "qux"})
        end

        it "creates empty nodes" do
          connection.should_receive(:post).with("/node")
          subject.create_empty
        end

        it "returns an empty node" do
          connection.stub(:post).and_return("foo")
          subject.create_empty.should == "foo"
        end

        it "creates empty nodes using #create method" do
          connection.should_receive(:post).with("/node")
          subject.create
        end

      end

      context "delete nodes" do

        it "deletes a node" do
          connection.should_receive(:delete).with("/node/42")
          subject.delete("42")
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
          connection.should_receive(:post).with("/node", options1)
          connection.should_receive(:post).with("/node", options2)

          subject.create_multiple([
            {:foo1 => "bar1", :baz1 => "qux1"},
            {:foo2 => "bar2", :baz2 => "qux2"}
          ])
        end

        it "returns multiple nodes with attributes in an array" do
          connection.stub(:post).and_return("foo", "bar")
          subject.create_multiple([{},{}]).should == ["foo", "bar"]
        end

        # exotic?
        it "creates multiple with and without attributes" do
          options1 = {
            :body    => '{"foo1":"bar1","baz1":"qux1"}',
            :headers => json_content_type
          }
          connection.should_receive(:post).with("/node", options1)
          connection.should_receive(:post).with("/node")

          subject.create_multiple([
            {:foo1 => "bar1", :baz1 => "qux1"},
            "not a hash" # ?
          ])
        end

        it "creates multiple empty nodes" do
          connection.should_receive(:post).with("/node").twice
          subject.create_multiple(2)
        end

        it "returns multiple empty nodes in an array" do
          connection.stub(:post).and_return("foo", "bar")
          subject.create_multiple(2).should == ["foo", "bar"]
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
          connection.should_receive(:post).with("/node", options1)
          connection.should_receive(:post).with("/node", options2)

          subject.create_multiple_threaded([
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
          connection.should_receive(:post).with("/node", options1)
          connection.should_receive(:post).with("/node")

          subject.create_multiple_threaded([
            {:foo1 => "bar1", :baz1 => "qux1"},
            "not a hash" # ?
          ])
        end

        it "creates multiple empty nodes" do
          connection.should_receive(:post).with("/node").twice
          subject.create_multiple_threaded(2)
        end

      end

    end
  end
end
