require 'spec_helper'

module Neography
  class Rest
    describe NodeRelationships do

      let(:connection) { double(:configuration => "http://configuration") }
      subject { NodeRelationships.new(connection) }

      it "creates a relationship" do
        body_hash = { "type" => "some_type",
          "to" => "http://configuration/node/43",
          "data" => {"foo"=>"bar","baz"=>"qux"}
        }
        connection.should_receive(:post).with("/node/42/relationships", json_match(:body, body_hash))

        subject.create("some_type", "42", "43", {:foo => "bar", :baz => "qux"})
      end

      it "returns the post results" do
        connection.stub(:post).and_return("foo")

        subject.create("some_type", "42", "43", {}).should == "foo"
      end

      it "gets relationships" do
        connection.should_receive(:get).with("/node/42/relationships/all")
        subject.get("42")
      end

      it "gets relationships with direction" do
        connection.should_receive(:get).with("/node/42/relationships/in")
        subject.get("42", :in)
      end

      it "gets relationships with direction and type" do
        connection.should_receive(:get).with("/node/42/relationships/in/foo")
        subject.get("42", :in, "foo")
      end

      it "gets relationships with direction and types" do
        connection.should_receive(:get).with("/node/42/relationships/in/foo&bar")
        subject.get("42", :in, ["foo", "bar"])
      end

      it "returns nil if no relationships were found" do
        connection.stub(:get).and_return(nil)
        subject.get("42", :in).should be_nil
      end

      it "returns nil if no relationships were found by type" do
        connection.stub(:get).and_return(nil)
        subject.get("42", :in, "foo")
      end

      context "directions" do

        [ :incoming, "incoming", :in, "in" ].each do |direction|
          it "parses 'in' direction" do
            NodeRelationships.new(nil).parse_direction(direction).should == "in"
          end
        end

        [ :outgoing, "outgoing", :out, "out" ].each do |direction|
          it "parses 'out' direction" do
            NodeRelationships.new(nil).parse_direction(direction).should == "out"
          end
        end

        it "parses 'all' direction by default" do
          NodeRelationships.new(nil).parse_direction("foo").should == "all"
        end

      end

    end
  end
end
