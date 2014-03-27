module Neography
  class Rest
    module NodeLabels
      include Neography::Rest::Helpers

      def list_labels
        @connection.get("/labels")
      end

      def get_node_labels(id)
        @connection.get("/node/%{id}/labels"  % {:id => get_id(id)})
      end

      def get_nodes_labeled(label)
        @connection.get("/label/%{label}/nodes" % {:label => label})
      end

      def find_nodes_labeled(label, hash)
        @connection.get("/label/%{label}/nodes?%{property}=%{value}"  % {:label => label, :property => hash.keys.first, :value => escape(hash.values.first)})
      end

      def add_label(id, label)
        options = {
          :body => (
            label
          ).to_json,
          :headers => json_content_type
        }
        @connection.post("/node/%{id}/labels"  % {:id => get_id(id)}, options)
      end

      def set_label(id, label)
        options = {
          :body => (
            Array(label)
          ).to_json,
          :headers => json_content_type
        }
        @connection.put("/node/%{id}/labels"  % {:id => get_id(id)}, options)
      end

      def delete_label(id, label)
        @connection.delete("/node/%{id}/labels/%{label}" % {:id => get_id(id), :label => label})
      end


    end
  end
end
