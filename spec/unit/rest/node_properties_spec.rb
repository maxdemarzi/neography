require 'spec_helper'

module Neography
  class Rest
    describe NodeProperties do

      subject { Neography::Rest.new }

      it "sets properties" do
        options1 = {
          :body    => '"bar"',
          :headers => json_content_type
        }
        options2 = {
          :body    => '"qux"',
          :headers => json_content_type
        }
        subject.connection.should_receive(:put).with("/node/42/properties/foo", options1)
        subject.connection.should_receive(:put).with("/node/42/properties/baz", options2)
        subject.set_node_properties("42", {:foo => "bar", :baz => "qux"})
      end

      it "resets properties" do
        options = {
          :body    => '{"foo":"bar"}',
          :headers => json_content_type
        }
        subject.connection.should_receive(:put).with("/node/42/properties", options)
        subject.reset_node_properties("42", {:foo => "bar"})
      end

      context "getting properties" do

        it "gets all properties" do
          subject.connection.should_receive(:get).with("/node/42/properties")
          subject.get_node_properties("42")
        end

        it "gets multiple properties" do
          subject.connection.should_receive(:get).with("/node/42/properties/foo")
          subject.connection.should_receive(:get).with("/node/42/properties/bar")
          subject.get_node_properties("42", "foo", "bar")
        end

        it "returns multiple properties as a hash" do
          subject.connection.stub(:get).and_return("baz", "qux")
          subject.get_node_properties("42", "foo", "bar").should == { "foo" => "baz", "bar" => "qux" }
        end

        it "returns nil if no properties were found" do
          subject.connection.stub(:get).and_return(nil, nil)
          subject.get_node_properties("42", "foo", "bar").should be_nil
        end

        it "returns hash without nil return values" do
          subject.connection.stub(:get).and_return("baz", nil)
          subject.get_node_properties("42", "foo", "bar").should == { "foo" => "baz" }
        end

      end

      context "removing properties" do

        it "removes all properties" do
          subject.connection.should_receive(:delete).with("/node/42/properties")
          subject.remove_node_properties("42")
        end

        it "removes multiple properties" do
          subject.connection.should_receive(:delete).with("/node/42/properties/foo")
          subject.connection.should_receive(:delete).with("/node/42/properties/bar")
          subject.remove_node_properties("42", "foo", "bar")
        end

      end

    end
  end
end
