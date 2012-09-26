require 'spec_helper'

module Neography
  describe Node do

    describe "::create" do
      context "no explicit server" do

        before do
          @db = mock(Neography::Rest, :is_a? => true).as_null_object
          Rest.stub(:new) { @db }
        end

        it "assigns a new Rest db by default" do
          node = Node.create
          node.neo_server.should == @db
        end

        it "creates without arguments" do
          @db.should_receive(:create_node).with(nil)
          Node.create
        end

        it "creates with only a hash argument" do
          properties = { :foo => "bar" }
          @db.should_receive(:create_node).with(properties)
          Node.create(properties)
        end

      end

      context "explicit server" do

        it "cannot pass a server as the first argument, properties as the second (deprecated)" do
          @other_server = Neography::Rest.new
          properties = { :foo => "bar" }
          @other_server.should_not_receive(:create_node).with(properties)
          expect {
            Node.create(@other_server, properties)
          }.to raise_error(ArgumentError)
        end

        it "can pass properties as the first argument, a server as the second" do
          @other_server = Neography::Rest.new
          properties = { :foo => "bar" }
          @other_server.should_receive(:create_node).with(properties)
          Node.create(properties, @other_server)
        end

      end
    end

    describe "::load" do
      context "no explicit server" do

        before do
          # stub out actual connections
          @db = stub(Rest).as_null_object
          Rest.stub(:new) { @db }
        end

        it "load by id" do
          @db.should_receive(:get_node).with(5)
          Node.load(5)
        end

        it "loads by node" do
          node = Node.new
          @db.should_receive(:get_node).with(node)
          Node.load(node)
        end

        it "loads by full server string" do
          @db.should_receive(:get_node).with("http://localhost:7474/db/data/node/2")
          Node.load("http://localhost:7474/db/data/node/2")
        end

      end

      context "explicit server" do

        it "cannot pass a server as the first argument, node as the second (depracted)" do
          @other_server = Neography::Rest.new
          @other_server.should_not_receive(:get_node).with(42)
          expect {
            node = Node.load(@other_server, 42)
          }.to raise_error(ArgumentError)
        end

        it "can pass a node as the first argument, server as the second" do
          @other_server = Neography::Rest.new
          @other_server.should_receive(:get_node).with(42)
          node = Node.load(42, @other_server)
        end

      end
    end

  end
end
