require 'spec_helper'

module Neography
  class Rest
    describe NodeIndexes do

      let(:connection) { double(:configuration => "http://configuration") }
      subject { NodeIndexes.new(connection) }

      it "lists all indexes" do
        connection.should_receive(:get).with("/index/node")
        subject.list
      end

      it "creates a node index" do
        expected_body = {
          "config" => {
            "type" => "some_type",
            "provider" => "some_provider"
          },
          "name" => "some_index"
        }
        connection.should_receive(:post).with("/index/node", json_match(:body, expected_body))
        subject.create("some_index", "some_type", "some_provider")
      end

      it "returns the post result after creation" do
        connection.stub(:post).and_return("foo")
        subject.create("some_index", "some_type", "some_provider").should == "foo"
      end

      it "creates an auto-index" do
        expected_body = {
          "config" => {
            "type" => "some_type",
            "provider" => "some_provider"
          },
          "name" => "node_auto_index"
        }
        connection.should_receive(:post).with("/index/node", json_match(:body, expected_body))
        subject.create_auto("some_type", "some_provider")
      end

      it "creates a unique node in an index" do
        expected_body = {
          "properties" => "properties",
          "key" => "key",
          "value" => "value"
        }
        connection.should_receive(:post).with("/index/node/some_index?unique", json_match(:body, expected_body))
        subject.create_unique("some_index", "key", "value", "properties")
      end

      it "gets or creates a unique node in an index" do
        expected_body = {
          "properties" => "properties",
          "key" => "key",
          "value" => "value"
        }
        connection.should_receive(:post).with("/index/node/some_index?uniqueness=get_or_create", json_match(:body, expected_body))
        subject.get_or_create_unique("some_index", "key", "value", "properties")
      end

      it "adds a node to an index" do
        expected_body = {
          "uri" => "http://configuration/node/42",
          "key" => "key",
          "value" => "value"
        }
        connection.should_receive(:post).with("/index/node/some_index", json_match(:body, expected_body))
        subject.add("some_index", "key", "value", "42")
      end

      it "gets a node from an index" do
        connection.should_receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.get("some_index", "some_key", "some_value")
      end

      it "returns nil if nothing was found in the index" do
        connection.stub(:get).and_return(nil)
        subject.get("some_index", "some_key", "some_value").should be_nil
      end

      it "finds by key and value if both passed to #find" do
        connection.should_receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.find("some_index", "some_key", "some_value")
      end

      it "finds by query if no value passed to #find" do
        connection.should_receive(:get).with("/index/node/some_index?query=some_query")
        subject.find("some_index", "some_query")
      end

      it "finds by key and value" do
        connection.should_receive(:get).with("/index/node/some_index/some_key/some_value")
        subject.find_by_key_value("some_index", "some_key", "some_value")
      end

      it "finds by query" do
        connection.should_receive(:get).with("/index/node/some_index?query=some_query")
        subject.find_by_query("some_index", "some_query")
      end

      it "removes a node from an index by id for #remove with two arguments" do
        connection.should_receive(:delete).with("/index/node/some_index/42")
        subject.remove("some_index", "42")
      end

      it "removes a node from an index by key for #remove with three arguments" do
        connection.should_receive(:delete).with("/index/node/some_index/some_key/42")
        subject.remove("some_index", "some_key", "42")
      end

      it "removes a node from an index by key and value for #remove with four arguments" do
        connection.should_receive(:delete).with("/index/node/some_index/some_key/some_value/42")
        subject.remove("some_index", "some_key", "some_value", "42")
      end

      it "removes a node from an index" do
        connection.should_receive(:delete).with("/index/node/some_index/42")
        subject.remove_by_id("some_index", "42")
      end

      it "removes a node from an index by key" do
        connection.should_receive(:delete).with("/index/node/some_index/some_key/42")
        subject.remove_by_key("some_index", "42", "some_key")
      end

      it "removes a node from an index by key and value" do
        connection.should_receive(:delete).with("/index/node/some_index/some_key/some_value/42")
        subject.remove_by_value("some_index", "42", "some_key", "some_value")
      end

      it "drops an index" do
        connection.should_receive(:delete).with("/index/node/some_index")
        subject.drop("some_index")
      end

    end
  end
end
