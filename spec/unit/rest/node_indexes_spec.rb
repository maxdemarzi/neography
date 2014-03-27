require 'spec_helper'

module Neography
  class Rest
    describe NodeIndexes do

      subject { Neography::Rest.new }

      it "lists all indexes" do
        subject.connection.should_receive(:get).with("/index/node")
        subject.list_node_indexes
      end

      it "creates a node index" do
        expected_body = {
          "config" => {
            "type" => "some_type",
            "provider" => "some_provider"
          },
          "name" => "some_index"
        }
        subject.connection.should_receive(:post).with("/index/node", json_match(:body, expected_body))
        subject.create_node_index("some_index", "some_type", "some_provider")
      end

      it "returns the post result after creation" do
        subject.connection.stub(:post).and_return("foo")
        subject.create_node_index("some_index", "some_type", "some_provider").should == "foo"
      end

      it "creates an auto-index" do
        expected_body = {
          "config" => {
            "type" => "some_type",
            "provider" => "some_provider"
          },
          "name" => "node_auto_index"
        }
        subject.connection.should_receive(:post).with("/index/node", json_match(:body, expected_body))
        subject.create_node_auto_index("some_type", "some_provider")
      end

      it "creates a unique node in an index" do
        expected_body = {
          "properties" => "properties",
          "key" => "key",
          "value" => "value"
        }
        subject.connection.should_receive(:post).with("/index/node/some_index?unique", json_match(:body, expected_body))
        subject.create_unique_node("some_index", "key", "value", "properties")
      end

      it "gets or creates a unique node in an index" do
        expected_body = {
          "properties" => "properties",
          "key" => "key",
          "value" => "value"
        }
        subject.connection.should_receive(:post).with("/index/node/some_index?uniqueness=get_or_create", json_match(:body, expected_body))
        subject.get_or_create_unique_node("some_index", "key", "value", "properties")
      end

      it "adds a node to an index" do
        expected_body = {
          "uri" => "http://localhost:7474/node/42",
          "key" => "key",
          "value" => "value"
        }
        subject.connection.should_receive(:post).with("/index/node/some_index", json_match(:body, expected_body))
        subject.add_node_to_index("some_index", "key", "value", "42")
      end

      it "gets a node from an index" do
        subject.connection.should_receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.get_node_index("some_index", "some_key", "some_value")
      end

      it "returns nil if nothing was found in the index" do
        subject.connection.stub(:get).and_return(nil)
        subject.get_node_index("some_index", "some_key", "some_value").should be_nil
      end

      it "finds by key and value if both passed to #find" do
        subject.connection.should_receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.find_node_index("some_index", "some_key", "some_value")
      end

      it "finds by query if no value passed to #find" do
        subject.connection.should_receive(:get).with("/index/node/some_index?query=some_query")
        subject.find_node_index("some_index", "some_query")
      end

      it "finds by key and value" do
        subject.connection.should_receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.find_node_index_by_key_value("some_index", "some_key", "some_value")
      end

      it "finds by query" do
        subject.connection.should_receive(:get).with("/index/node/some_index?query=some_query")
        subject.find_node_index_by_query("some_index", "some_query")
      end

      it "removes a node from an index by id for #remove with two arguments" do
        subject.connection.should_receive(:delete).with("/index/node/some_index/42")
        subject.remove_node_from_index("some_index", "42")
      end

      it "removes a node from an index by key for #remove with three arguments" do
        subject.connection.should_receive(:delete).with("/index/node/some_index/some_key/42")
        subject.remove_node_from_index("some_index", "some_key", "42")
      end

      it "removes a node from an index by key and value for #remove with four arguments" do
        subject.connection.should_receive(:delete).with("/index/node/some_index/some_key/some_value/42")
        subject.remove_node_from_index("some_index", "some_key", "some_value", "42")
      end

      it "removes a node from an index" do
        subject.connection.should_receive(:delete).with("/index/node/some_index/42")
        subject.remove_node_index_by_id("some_index", "42")
      end

      it "removes a node from an index by key" do
        subject.connection.should_receive(:delete).with("/index/node/some_index/some_key/42")
        subject.remove_node_index_by_key("some_index", "42", "some_key")
      end

      it "removes a node from an index by key and value" do
        subject.connection.should_receive(:delete).with("/index/node/some_index/some_key/some_value/42")
        subject.remove_node_index_by_value("some_index", "42", "some_key", "some_value")
      end

      it "drops an index" do
        subject.connection.should_receive(:delete).with("/index/node/some_index")
        subject.drop_node_index("some_index")
      end

    end
  end
end
