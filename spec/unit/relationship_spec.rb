require 'spec_helper'

module Neography
  describe Relationship do

    let(:db) { double(Rest).as_null_object }
    let(:relationship_hash) do
      {
        "self" => "0",
        "start" => "1",
        "end" => "2",
        "data" => {}
      }
    end

    let(:from)  { double(:neo_server => db) }
    let(:to)    { double(:neo_server => db) }
    let(:props) { { :foo => "bar" } }

    describe "::create" do
      it "creates a new node through Rest" do
        db.should_receive(:create_relationship).with("type", from, to, props)

        Relationship.create("type", from, to, props)
      end

      it "assigns fields" do
        db.stub(:create_relationship).and_return(relationship_hash)

        rel = Relationship.create("type", from, to, props)

        rel.start_node.should == from
        rel.end_node.should   == to
        rel.rel_type.should   == "type"
      end
    end

    describe "::load" do
      context "no explicit server" do

        before do
          # stub out actual connections
          @db = double(Rest).as_null_object
          Rest.stub(:new) { @db }
        end

        it "load by id" do
          @db.should_receive(:get_relationship).with(5)
          Relationship.load(5)
        end

        it "loads by relationship" do
          relationship = Relationship.new(relationship_hash)
          @db.should_receive(:get_relationship).with(relationship)
          Relationship.load(relationship)
        end

        it "loads by full server string" do
          @db.should_receive(:get_relationship).with("http://localhost:7474/db/data/relationship/2")
          Relationship.load("http://localhost:7474/db/data/relationship/2")
        end

      end

      context "explicit server" do

        it "cannot pass a server as the first argument, relationship as the second" do
          @other_server = Neography::Rest.new
          @other_server.should_not_receive(:get_relationship).with(42)
          expect {
            relationship = Relationship.load(@other_server, 42)
          }.to raise_error(ArgumentError)
        end

        it "can pass a relationship as the first argument, server as the second" do
          @other_server = Neography::Rest.new
          @other_server.should_receive(:get_relationship).with(42)
          relationship = Relationship.load(42, @other_server)
        end

      end
    end

    describe "#del" do

      before do
        db.stub(:create_relationship) { relationship_hash }
      end

      subject(:relationship) { Relationship.create("type", from, to, props) }

      it "deletes a node" do
        db.should_receive(:delete_relationship).with("0")
        relationship.del
      end

    end

    describe "#other_node" do

      before do
        db.stub(:create_relationship) { relationship_hash }
      end

      subject(:relationship) { Relationship.create("type", from, to, props) }

      it "knows the other node based on from" do
        relationship.other_node(from).should == to
      end

      it "knows the other node based on to" do
        relationship.other_node(to).should == from
      end

    end

  end
end
