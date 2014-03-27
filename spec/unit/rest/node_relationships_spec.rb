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
        subject.connection.should_receive(:post).with("/node/42/relationships", json_match(:body, body_hash))

        subject.create_relationship("some_type", "42", "43", {:foo => "bar", :baz => "qux"})
      end

      it "returns the post results" do
        subject.connection.stub(:post).and_return("foo")

        subject.create_relationship("some_type", "42", "43", {}).should == "foo"
      end

      it "gets relationships" do
        subject.connection.should_receive(:get).with("/node/42/relationships/all")
        subject.get_node_relationships("42")
      end

      it "gets relationships with direction" do
        subject.connection.should_receive(:get).with("/node/42/relationships/in")
        subject.get_node_relationships("42", :in)
      end

      it "gets relationships with direction and type" do
        subject.connection.should_receive(:get).with("/node/42/relationships/in/foo")
        subject.get_node_relationships("42", :in, "foo")
      end

      it "gets relationships with direction and types" do
        subject.connection.should_receive(:get).with("/node/42/relationships/in/foo%26bar")
        subject.get_node_relationships("42", :in, ["foo", "bar"])
      end

      it "returns empty array if no relationships were found" do
        subject.connection.stub(:get).and_return([])
        subject.get_node_relationships("42", :in).should be_empty
      end

      it "returns empty array if no relationships were found by type" do
        subject.connection.stub(:get).and_return([])
        subject.get_node_relationships("42", :in, "foo")
      end

    end
  end
end
