require 'spec_helper'

module Neography
  class Rest
    describe RelationshipIndexes do

      subject { Neography::Rest.new }

      it "lists all indexes" do
        subject.connection.should_receive(:get).with("/index/relationship")
        subject.list_relationship_indexes
      end

      it "creates a relationship index" do
        expected_body = {
          "config" => {
            "type" => "some_type",
            "provider" => "some_provider"
          },
          "name" => "some_index"
        }
        subject.connection.should_receive(:post).with("/index/relationship", json_match(:body, expected_body))
        subject.create_relationship_index("some_index", "some_type", "some_provider")
      end

      it "returns the post result after creation" do
        subject.connection.stub(:post).and_return("foo")
        subject.create_relationship_index("some_index", "some_type", "some_provider").should == "foo"
      end

      it "creates an auto-index" do
        expected_body = {
          "config" => {
            "type" => "some_type",
            "provider" => "some_provider"
          },
          "name" => "relationship_auto_index"
        }
        subject.connection.should_receive(:post).with("/index/relationship", json_match(:body, expected_body))
        subject.create_relationship_auto_index("some_type", "some_provider")
      end

      it "creates a unique relationship in an index" do
        expected_body = {
          "key"        => "key",
          "value"      => "value",
          "type"       => "type",
          "start"      => "http://localhost:7474/node/42",
          "end"        => "http://localhost:7474/node/43",
          "properties" => "properties"
        }
        subject.connection.should_receive(:post).with("/index/relationship/some_index?unique", json_match(:body, expected_body))
        subject.create_unique_relationship("some_index", "key", "value", "type", "42", "43", "properties")
      end

      it "adds a relationship to an index" do
        expected_body = {
          "uri" => "http://localhost:7474/relationship/42",
          "key" => "key",
          "value" => "value"
        }
        subject.connection.should_receive(:post).with("/index/relationship/some_index", json_match(:body, expected_body))
        subject.add_relationship_to_index("some_index", "key", "value", "42")
      end

      it "gets a relationship from an index" do
        subject.connection.should_receive(:get).with("/index/relationship/some_index/some_key/some_value")
        subject.get_relationship_index("some_index", "some_key", "some_value")
      end

      it "returns nil if nothing was found in the index" do
        subject.connection.stub(:get).and_return(nil)
        subject.get_relationship_index("some_index", "some_key", "some_value").should be_nil
      end

      it "finds by key and value if both passed to #find" do
        subject.connection.should_receive(:get).with("/index/relationship/some_index/some_key/some_value")
        subject.find_relationship_index("some_index", "some_key", "some_value")
      end

      it "finds by query if no value passed to #find" do
        subject.connection.should_receive(:get).with("/index/relationship/some_index?query=some_query")
        subject.find_relationship_index("some_index", "some_query")
      end

      it "finds by key query" do
        subject.connection.should_receive(:get).with("/index/relationship/some_index/some_key/some_value")
        subject.find_relationship_index_by_key_value("some_index", "some_key", "some_value")
      end

      it "finds by query" do
        subject.connection.should_receive(:get).with("/index/relationship/some_index?query=some_query")
        subject.find_relationship_index_by_query("some_index", "some_query")
      end

      it "removes a relationship from an index for #remove with two arguments" do
        subject.connection.should_receive(:delete).with("/index/relationship/some_index/42")
        subject.remove_relationship_from_index("some_index", "42")
      end

      it "removes a relationship from an index by key for #remove with three arguments" do
        subject.connection.should_receive(:delete).with("/index/relationship/some_index/some_key/42")
        subject.remove_relationship_from_index("some_index", "some_key", "42")
      end

      it "removes a relationship from an index by key and value for #remove with four arguments" do
        subject.connection.should_receive(:delete).with("/index/relationship/some_index/some_key/some_value/42")
        subject.remove_relationship_from_index("some_index", "some_key", "some_value", "42")
      end

      it "removes a relationship from an index" do
        subject.connection.should_receive(:delete).with("/index/relationship/some_index/42")
        subject.remove_relationship_index_by_id("some_index", "42")
      end

      it "removes a relationship from an index by key" do
        subject.connection.should_receive(:delete).with("/index/relationship/some_index/some_key/42")
        subject.remove_relationship_index_by_key("some_index", "42", "some_key")
      end

      it "removes a relationship from an index by key and value" do
        subject.connection.should_receive(:delete).with("/index/relationship/some_index/some_key/some_value/42")
        subject.remove_relationship_index_by_value("some_index", "42", "some_key", "some_value")
      end

      it "drops an index" do
        subject.connection.should_receive(:delete).with("/index/relationship/some_index")
        subject.drop_relationship_index("some_index")
      end
    end
  end
end
