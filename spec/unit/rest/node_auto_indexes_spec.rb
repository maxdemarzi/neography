require 'spec_helper'

module Neography
  class Rest
    describe NodeAutoIndexes do

      let(:connection) { double }
      subject { NodeAutoIndexes.new(connection) }

      it "gets a node from an auto index" do
        connection.should_receive(:get).with("/index/auto/node/some_key/some_value")
        subject.get("some_key", "some_value")
      end

      it "returns nil if nothing was found in the auto index" do
        connection.stub(:get).and_return(nil)
        subject.get("some_key", "some_value").should be_nil
      end

      it "finds by key and value if value passed to #find_or_query" do
        connection.should_receive(:get).with("/index/auto/node/some_key/some_value")
        subject.find_or_query("some_key", "some_value")
      end

      it "finds by query if no value passed to #find_or_query" do
        connection.should_receive(:get).with("/index/auto/node/?query=some_query")
        subject.find_or_query("some_query")
      end

      it "finds by key and value" do
        connection.should_receive(:get).with("/index/auto/node/some_key/some_value")
        subject.find("some_key", "some_value")
      end

      it "finds by query" do
        connection.should_receive(:get).with("/index/auto/node/?query=some_query")
        subject.query("some_query")
      end

      it "gets the status" do
        connection.should_receive(:get).with("/index/auto/node/status")
        subject.status
      end

      it "sets the status" do
        connection.should_receive(:put).with("/index/auto/node/status", hash_match(:body, '"foo"'))
        subject.status = "foo"
      end

      it "gets auto index properties" do
        connection.should_receive(:get).with("/index/auto/node/properties")
        subject.properties
      end

      it "adds a property to an auto index" do
        connection.should_receive(:post).with("/index/auto/node/properties", hash_match(:body, "foo"))
        subject.add_property("foo")
      end

      it "removes a property from an auto index" do
        connection.should_receive(:delete).with("/index/auto/node/properties/foo")
        subject.remove_property("foo")
      end

    end
  end
end
