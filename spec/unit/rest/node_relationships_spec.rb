require 'spec_helper'

module Neography
  class Rest
    describe NodeRelationships do

      subject { Neography::Rest.new }

      it "creates a relationship" do
        body_hash = { "type" => "some_type",
          "to" => "http://localhost:7474/node/43",
          "data" => {"foo"=>"bar","baz"=>"qux"}
        }
        expect(subject.connection).to receive(:post).with("/node/42/relationships", json_match(:body, body_hash))

        subject.create_relationship("some_type", "42", "43", {:foo => "bar", :baz => "qux"})
      end

      it "returns the post results" do
        allow(subject.connection).to receive(:post).and_return("foo")

        expect(subject.create_relationship("some_type", "42", "43", {})).to eq("foo")
      end

      it "gets relationships" do
        expect(subject.connection).to receive(:get).with("/node/42/relationships/all")
        subject.get_node_relationships("42")
      end

      it "gets relationships with direction" do
        expect(subject.connection).to receive(:get).with("/node/42/relationships/in")
        subject.get_node_relationships("42", :in)
      end

      it "gets relationships with direction and type" do
        expect(subject.connection).to receive(:get).with("/node/42/relationships/in/foo")
        subject.get_node_relationships("42", :in, "foo")
      end

      it "gets relationships with direction and types" do
        expect(subject.connection).to receive(:get).with("/node/42/relationships/in/foo%26bar")
        subject.get_node_relationships("42", :in, ["foo", "bar"])
      end

      it "returns empty array if no relationships were found" do
        allow(subject.connection).to receive(:get).and_return([])
        expect(subject.get_node_relationships("42", :in)).to be_empty
      end

      it "returns empty array if no relationships were found by type" do
        allow(subject.connection).to receive(:get).and_return([])
        subject.get_node_relationships("42", :in, "foo")
      end

    end
  end
end
