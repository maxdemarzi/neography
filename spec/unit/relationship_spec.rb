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
        expect(db).to receive(:create_relationship).with("type", from, to, props)

        Relationship.create("type", from, to, props)
      end

      it "assigns fields" do
        allow(db).to receive(:create_relationship).and_return(relationship_hash)

        rel = Relationship.create("type", from, to, props)

        expect(rel.start_node).to eq(from)
        expect(rel.end_node).to   eq(to)
        expect(rel.rel_type).to   eq("type")
      end
    end

    describe "::load" do
      context "no explicit server" do

        before do
          # stub out actual connections
          @db = double(Rest).as_null_object
          allow(Rest).to receive(:new) { @db }
        end

        it "load by id" do
          expect(@db).to receive(:get_relationship).with(5)
          Relationship.load(5)
        end

        it "loads by relationship" do
          relationship = Relationship.new(relationship_hash)
          expect(@db).to receive(:get_relationship).with(relationship)
          Relationship.load(relationship)
        end

        it "loads by full server string" do
          expect(@db).to receive(:get_relationship).with("http://localhost:7474/db/data/relationship/2")
          Relationship.load("http://localhost:7474/db/data/relationship/2")
        end

      end

      context "explicit server" do

        it "cannot pass a server as the first argument, relationship as the second" do
          @other_server = Neography::Rest.new
          expect(@other_server).not_to receive(:get_relationship).with(42)
          expect {
            relationship = Relationship.load(@other_server, 42)
          }.to raise_error(ArgumentError)
        end

        it "can pass a relationship as the first argument, server as the second" do
          @other_server = Neography::Rest.new
          expect(@other_server).to receive(:get_relationship).with(42)
          relationship = Relationship.load(42, @other_server)
        end

      end
    end

    describe "#del" do

      before do
        allow(db).to receive(:create_relationship) { relationship_hash }
      end

      subject(:relationship) { Relationship.create("type", from, to, props) }

      it "deletes a node" do
        expect(db).to receive(:delete_relationship).with("0")
        relationship.del
      end

    end

    describe "#other_node" do

      before do
        allow(db).to receive(:create_relationship) { relationship_hash }
      end

      subject(:relationship) { Relationship.create("type", from, to, props) }

      it "knows the other node based on from" do
        expect(relationship.other_node(from)).to eq(to)
      end

      it "knows the other node based on to" do
        expect(relationship.other_node(to)).to eq(from)
      end

    end

  end
end
