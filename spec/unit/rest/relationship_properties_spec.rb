require 'spec_helper'

module Neography
  class Rest
    describe RelationshipProperties do

      let(:connection) { double }
      subject { RelationshipProperties.new(connection) }

      it "sets properties" do
        options1 = {
          :body    => '"bar"',
          :headers => json_content_type
        }
        options2 = {
          :body    => '"qux"',
          :headers => json_content_type
        }
        connection.should_receive(:put).with("/relationship/42/properties/foo", options1)
        connection.should_receive(:put).with("/relationship/42/properties/baz", options2)
        subject.set("42", {:foo => "bar", :baz => "qux"})
      end

      it "resets properties" do
        options = {
          :body    => '{"foo":"bar"}',
          :headers => json_content_type
        }
        connection.should_receive(:put).with("/relationship/42/properties", options)
        subject.reset("42", {:foo => "bar"})
      end

      context "getting properties" do

        it "gets all properties" do
          connection.should_receive(:get).with("/relationship/42/properties")
          subject.get("42")
        end

        it "gets multiple properties" do
          connection.should_receive(:get).with("/relationship/42/properties/foo")
          connection.should_receive(:get).with("/relationship/42/properties/bar")
          subject.get("42", "foo", "bar")
        end

        it "returns multiple properties as a hash" do
          connection.stub(:get).and_return("baz", "qux")
          subject.get("42", "foo", "bar").should == { "foo" => "baz", "bar" => "qux" }
        end

        it "returns nil if no properties were found" do
          connection.stub(:get).and_return(nil, nil)
          subject.get("42", "foo", "bar").should be_nil
        end

        it "returns hash without nil return values" do
          connection.stub(:get).and_return("baz", nil)
          subject.get("42", "foo", "bar").should == { "foo" => "baz" }
        end

      end

      context "removing properties" do

        it "removes all properties" do
          connection.should_receive(:delete).with("/relationship/42/properties")
          subject.remove("42")
        end

        it "removes multiple properties" do
          connection.should_receive(:delete).with("/relationship/42/properties/foo")
          connection.should_receive(:delete).with("/relationship/42/properties/bar")
          subject.remove("42", "foo", "bar")
        end

      end

    end
  end
end
