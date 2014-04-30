require 'spec_helper'

module Neography
  class Rest
    describe NodeAutoIndexes do

      subject { Neography::Rest.new }

      it "gets a node from an auto index" do
        subject.connection.should_receive(:get).with("/index/auto/node/some_key/some_value")
        subject.get_node_auto_index("some_key", "some_value")
      end

      it "returns nil if nothing was found in the auto index" do
        subject.connection.stub(:get).and_return(nil)
        subject.get_node_auto_index("some_key", "some_value").should be_nil
      end

      it "finds by key and value if value passed to #find_or_query" do
        subject.connection.should_receive(:get).with("/index/auto/node/some_key/some_value")
        subject.find_node_auto_index("some_key", "some_value")
      end

      it "finds by query if no value passed to #find_or_query" do
        subject.connection.should_receive(:get).with("/index/auto/node/?query=some_query")
        subject.find_node_auto_index("some_query")

        query = "some_query AND another_one"
        subject.connection.should_receive(:get).with("/index/auto/node/?query=#{URI.encode(query)}")
        subject.find_node_auto_index(query)
      end

      it "finds by key and value" do
        subject.connection.should_receive(:get).with("/index/auto/node/some_key/some_value")
        subject.find_node_auto_index("some_key", "some_value")
      end

      it "finds by query" do
        subject.connection.should_receive(:get).with("/index/auto/node/?query=some_query")
        subject.find_node_auto_index("some_query")
      end

      it "gets the status" do
        subject.connection.should_receive(:get).with("/index/auto/node/status")
        subject.get_node_auto_index_status
      end

      it "sets the status" do
        subject.connection.should_receive(:put).with("/index/auto/node/status", hash_match(:body, '"foo"'))
        subject.set_node_auto_index_status("foo")
      end

      it "gets auto index properties" do
        subject.connection.should_receive(:get).with("/index/auto/node/properties")
        subject.get_node_auto_index_properties
      end

      it "adds a property to an auto index" do
        subject.connection.should_receive(:post).with("/index/auto/node/properties", hash_match(:body, "foo"))
        subject.add_node_auto_index_property("foo")
      end

      it "removes a property from an auto index" do
        subject.connection.should_receive(:delete).with("/index/auto/node/properties/foo")
        subject.remove_node_auto_index_property("foo")
      end

    end
  end
end
