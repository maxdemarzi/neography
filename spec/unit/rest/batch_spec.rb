require 'spec_helper'

module Neography
  class Rest
    describe Batch do

      let(:connection) { double(:gremlin_path => "/gremlin", :cypher_path => "/cypher") }
      subject { Batch.new(connection) }

      it "gets nodes" do
        expected_body = [
          { "id" => 0, "method" => "GET", "to" => "/node/foo" },
          { "id" => 1, "method" => "GET", "to" => "/node/bar" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:get_node, "foo"], [:get_node, "bar"]
      end

      it "creates nodes" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "/node", "body" => { "foo" => "bar" } },
          { "id" => 1, "method" => "POST", "to" => "/node", "body" => { "baz" => "qux" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:create_node, { "foo" => "bar" }], [:create_node, { "baz" => "qux" }]
      end

      it "deletes nodes" do
        expected_body = [
          { "id" => 0, "method" => "DELETE", "to" => "/node/foo" },
          { "id" => 1, "method" => "DELETE", "to" => "/node/bar" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:delete_node, "foo"], [:delete_node, "bar"]
      end

      it "creates unique nodes" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "/index/node/foo?unique",  "body" => { "key" => "bar",   "value" => "baz",    "properties" => "qux"    } },
          { "id" => 1, "method" => "POST", "to" => "/index/node/quux?unique", "body" => { "key" => "corge", "value" => "grault", "properties" => "garply" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:create_unique_node, "foo", "bar", "baz", "qux" ],
                        [:create_unique_node, "quux", "corge", "grault", "garply"]
      end

      it "adds nodes to an index" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "/index/node/foo",  "body" => { "uri" => "/node/qux",    "key" => "bar",   "value" => "baz"    } },
          { "id" => 1, "method" => "POST", "to" => "/index/node/quux", "body" => { "uri" => "{0}", "key" => "corge", "value" => "grault" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:add_node_to_index, "foo", "bar", "baz", "qux" ],
                        [:add_node_to_index, "quux", "corge", "grault", "{0}"]
      end

      it "gets nodes from an index" do
        expected_body = [
          { "id" => 0, "method" => "GET", "to" => "/index/node/foo/bar/baz" },
          { "id" => 1, "method" => "GET", "to" => "/index/node/qux/quux/corge" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:get_node_index, "foo", "bar", "baz" ],
                        [:get_node_index, "qux", "quux", "corge" ]
      end

      it "deletes nodes from an index" do
        expected_body = [
          { "id" => 0, "method" => "DELETE", "to" => "/index/node/index1/id1" },
          { "id" => 1, "method" => "DELETE", "to" => "/index/node/index2/key2/id2" },
          { "id" => 2, "method" => "DELETE", "to" => "/index/node/index3/key3/value3/id3" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:remove_node_from_index, "index1", "id1", ],
                        [:remove_node_from_index, "index2", "key2", "id2" ],
                        [:remove_node_from_index, "index3", "key3", "value3", "id3" ]
      end

      it "sets node properties" do
        expected_body = [
          { "id" => 0, "method" => "PUT", "to" => "/node/index1/properties/key1", "body" => "value1" },
          { "id" => 1, "method" => "PUT", "to" => "/node/index2/properties/key2", "body" => "value2" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:set_node_property, "index1", { "key1" => "value1" } ],
                        [:set_node_property, "index2", { "key2" => "value2" } ]
      end

      it "resets node properties" do
        expected_body = [
          { "id" => 0, "method" => "PUT", "to" => "/node/index1/properties", "body" => { "key1" => "value1" } },
          { "id" => 1, "method" => "PUT", "to" => "/node/index2/properties", "body" => { "key2" => "value2" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:reset_node_properties, "index1", { "key1" => "value1" } ],
                        [:reset_node_properties, "index2", { "key2" => "value2" } ]
      end

      it "adds a node label" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "{0}/labels", "body" => "foo" },
          { "id" => 1, "method" => "POST", "to" => "{0}/labels", "body" => "bar" },
        ]
        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:add_label, "{0}", "foo"],
                        [:add_label, "{0}", "bar"]
      end

      it "gets node relationships" do
        expected_body = [
          { "id" => 0, "method" => "GET", "to" => "/node/id1/relationships/direction1" },
          { "id" => 1, "method" => "GET", "to" => "/node/id2/relationships/all" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:get_node_relationships, "id1", "direction1" ],
                        [:get_node_relationships, "id2" ]
      end

      it "gets relationships" do
        expected_body = [
          { "id" => 0, "method" => "GET", "to" => "/relationship/foo" },
          { "id" => 1, "method" => "GET", "to" => "/relationship/bar" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:get_relationship, "foo"], [:get_relationship, "bar"]
      end

      it "creates relationships" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "/node/from1/relationships", "body" => { "to" => "/node/to1", "type" => "type1", "data" => "data1" } },
          { "id" => 1, "method" => "POST", "to" => "{0}/relationships", "body" => { "to" => "{1}", "type" => "type2", "data" => "data2" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:create_relationship, "type1", "from1", "to1", "data1" ],
                        [:create_relationship, "type2", "{0}", "{1}", "data2" ]
      end

      it "deletes relationships" do
        expected_body = [
          { "id" => 0, "method" => "DELETE", "to" => "/relationship/foo" },
          { "id" => 1, "method" => "DELETE", "to" => "/relationship/bar" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:delete_relationship, "foo"], [:delete_relationship, "bar"]
      end

      it "creates unique nodes" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "/index/relationship/index1?unique", "body" => { "key" => "key1", "value" => "value1", "type" => "type1", "start" => "/node/node1", "end" => "/node/node2" } },
          { "id" => 1, "method" => "POST", "to" => "/index/relationship/index2?unique", "body" => { "key" => "key2", "value" => "value2", "type" => "type2", "start" => "{0}", "end" => "{1}" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:create_unique_relationship, "index1", "key1", "value1", "type1", "node1", "node2" ],
                        [:create_unique_relationship, "index2", "key2", "value2", "type2", "{0}", "{1}" ]
      end

      it "adds relationships to an index" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "/index/relationship/index1", "body" => { "uri" => "/relationship/rel1", "key" => "key1", "value" => "value1" } },
          { "id" => 1, "method" => "POST", "to" => "/index/relationship/index2", "body" => { "uri" => "{0}", "key" => "key2", "value" => "value2" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:add_relationship_to_index, "index1", "key1", "value1", "rel1" ],
                        [:add_relationship_to_index, "index2", "key2", "value2", "{0}"]
      end

      it "gets relationships from an index" do
        expected_body = [
          { "id" => 0, "method" => "GET", "to" => "/index/relationship/foo/bar/baz" },
          { "id" => 1, "method" => "GET", "to" => "/index/relationship/qux/quux/corge" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:get_relationship_index, "foo", "bar", "baz" ],
                        [:get_relationship_index, "qux", "quux", "corge" ]
      end

      it "deletes relationships from an index" do
        expected_body = [
          { "id" => 0, "method" => "DELETE", "to" => "/index/relationship/index1/id1" },
          { "id" => 1, "method" => "DELETE", "to" => "/index/relationship/index2/key2/id2" },
          { "id" => 2, "method" => "DELETE", "to" => "/index/relationship/index3/key3/value3/id3" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:remove_relationship_from_index, "index1", "id1", ],
                        [:remove_relationship_from_index, "index2", "key2", "id2" ],
                        [:remove_relationship_from_index, "index3", "key3", "value3", "id3" ]
      end

      it "sets relationship properties" do
        expected_body = [
          { "id" => 0, "method" => "PUT", "to" => "/relationship/index1/properties/key1", "body" => "value1" },
          { "id" => 1, "method" => "PUT", "to" => "/relationship/index2/properties/key2", "body" => "value2" }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:set_relationship_property, "index1", { "key1" => "value1" } ],
                        [:set_relationship_property, "index2", { "key2" => "value2" } ]
      end

      it "resets relationship properties" do
        expected_body = [
          { "id" => 0, "method" => "PUT", "to" => "/relationship/index1/properties", "body" => { "key1" => "value1" } },
          { "id" => 1, "method" => "PUT", "to" => "{0}/properties", "body" => { "key2" => "value2" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:reset_relationship_properties, "index1", { "key1" => "value1" } ],
                        [:reset_relationship_properties, "{0}", { "key2" => "value2" } ]
      end

      it "executes scripts" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "/gremlin", "body" => { "script" => "script1", "params" => "params1" } },
          { "id" => 1, "method" => "POST", "to" => "/gremlin", "body" => { "script" => "script2", "params" => "params2" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:execute_script, "script1", "params1"],
                        [:execute_script, "script2", "params2"]
      end

      it "executes queries" do
        expected_body = [
          { "id" => 0, "method" => "POST", "to" => "/cypher", "body" => { "query" => "query1", "params" => "params1" } },
          { "id" => 1, "method" => "POST", "to" => "/cypher", "body" => { "query" => "query2" } }
        ]

        connection.should_receive(:post).with("/batch", json_match(:body, expected_body))
        subject.execute [:execute_query, "query1", "params1"],
                        [:execute_query, "query2" ]
      end

    end
  end
end

