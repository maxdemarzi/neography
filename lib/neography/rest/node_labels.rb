module Neography
  class Rest
    class NodeLabels
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :base,      "/labels"
      add_path :node,      "/node/:id/labels"
      add_path :nodes,     "/label/:label/nodes"
      add_path :find,      "/label/:label/nodes?:property=%22:value%22"
      add_path :delete,    "/node/:id/labels/:label"

      def initialize(connection)
        @connection = connection
      end

      def list
        @connection.get(base_path)
      end

      def get(id)
        @connection.get(node_path(:id => get_id(id)))
      end

      def get_nodes(label)
        @connection.get(nodes_path(:label => label))
      end

      def find_nodes(label, hash)
        @connection.get(find_path(:label => label, :property => hash.keys.first, :value => hash.values.first))
      end

      def add(id, label)
        options = {
          :body => (
            label
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(node_path(:id => get_id(id)), options)
      end

      def set(id, label)
        options = {
          :body => (
            Array(label)
          ).to_json,
          :headers => json_content_type
        }
        @connection.put(node_path(:id => get_id(id)), options)
      end

      def delete(id, label)
        @connection.delete(delete_path(:id => get_id(id), :label => label))
      end


    end
  end
end
