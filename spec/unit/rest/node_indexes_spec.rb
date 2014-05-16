require 'spec_helper'

module Neography
  class Rest
    describe NodeIndexes do

      subject { Neography::Rest.new }

      it "lists all indexes" do
        expect(subject.connection).to receive(:get).with("/index/node")
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
        expect(subject.connection).to receive(:post).with("/index/node", json_match(:body, expected_body))
        subject.create_node_index("some_index", "some_type", "some_provider")
      end

      it "returns the post result after creation" do
        allow(subject.connection).to receive(:post).and_return("foo")
        expect(subject.create_node_index("some_index", "some_type", "some_provider")).to eq("foo")
      end

      it "creates an auto-index" do
        expected_body = {
          "config" => {
            "type" => "some_type",
            "provider" => "some_provider"
          },
          "name" => "node_auto_index"
        }
        expect(subject.connection).to receive(:post).with("/index/node", json_match(:body, expected_body))
        subject.create_node_auto_index("some_type", "some_provider")
      end

      it "creates a unique node in an index" do
        expected_body = {
          "properties" => "properties",
          "key" => "key",
          "value" => "value"
        }
        expect(subject.connection).to receive(:post).with("/index/node/some_index?unique", json_match(:body, expected_body))
        subject.create_unique_node("some_index", "key", "value", "properties")
      end

      it "gets or creates a unique node in an index" do
        expected_body = {
          "properties" => "properties",
          "key" => "key",
          "value" => "value"
        }
        expect(subject.connection).to receive(:post).with("/index/node/some_index?uniqueness=get_or_create", json_match(:body, expected_body))
        subject.get_or_create_unique_node("some_index", "key", "value", "properties")
      end

      it "adds a node to an index" do
        expected_body = {
          "uri" => "http://localhost:7474/node/42",
          "key" => "key",
          "value" => "value"
        }
        expect(subject.connection).to receive(:post).with("/index/node/some_index", json_match(:body, expected_body))
        subject.add_node_to_index("some_index", "key", "value", "42")
      end

      it "gets a node from an index" do
        expect(subject.connection).to receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.get_node_index("some_index", "some_key", "some_value")
      end

      it "returns nil if nothing was found in the index" do
        allow(subject.connection).to receive(:get).and_return(nil)
        expect(subject.get_node_index("some_index", "some_key", "some_value")).to be_nil
      end

      it "finds by key and value if both passed to #find" do
        expect(subject.connection).to receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.find_node_index("some_index", "some_key", "some_value")
      end

      it "finds by query if no value passed to #find" do
        expect(subject.connection).to receive(:get).with("/index/node/some_index?query=some_query")
        subject.find_node_index("some_index", "some_query")
      end

      it "finds by key and value" do
        expect(subject.connection).to receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.find_node_index_by_key_value("some_index", "some_key", "some_value")
      end

      it "finds by query" do
        expect(subject.connection).to receive(:get).with("/index/node/some_index?query=some_query")
        subject.find_node_index_by_query("some_index", "some_query")
      end

      it "removes a node from an index by id for #remove with two arguments" do
        expect(subject.connection).to receive(:delete).with("/index/node/some_index/42")
        subject.remove_node_from_index("some_index", "42")
      end

      it "removes a node from an index by key for #remove with three arguments" do
        expect(subject.connection).to receive(:delete).with("/index/node/some_index/some_key/42")
        subject.remove_node_from_index("some_index", "some_key", "42")
      end

      it "removes a node from an index by key and value for #remove with four arguments" do
        expect(subject.connection).to receive(:delete).with("/index/node/some_index/some_key/some_value/42")
        subject.remove_node_from_index("some_index", "some_key", "some_value", "42")
      end

      it "removes a node from an index" do
        expect(subject.connection).to receive(:delete).with("/index/node/some_index/42")
        subject.remove_node_index_by_id("some_index", "42")
      end

      it "removes a node from an index by key" do
        expect(subject.connection).to receive(:delete).with("/index/node/some_index/some_key/42")
        subject.remove_node_index_by_key("some_index", "42", "some_key")
      end

      it "removes a node from an index by key and value" do
        expect(subject.connection).to receive(:delete).with("/index/node/some_index/some_key/some_value/42")
        subject.remove_node_index_by_value("some_index", "42", "some_key", "some_value")
      end

      it "drops an index" do
        expect(subject.connection).to receive(:delete).with("/index/node/some_index")
        subject.drop_node_index("some_index")
      end

    end
  end
end
