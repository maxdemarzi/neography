module Neography
  class Rest
    class NodeTraversal
      include Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :traversal, "/node/:id/traverse/:type"

      def initialize(connection)
        @connection = connection
      end

      def traverse(id, return_type, description)
        options = { :body => {
            "order"           => get_order(description["order"]),
            "uniqueness"      => get_uniqueness(description["uniqueness"]),
            "relationships"   => description["relationships"],
            "prune_evaluator" => description["prune evaluator"],
            "return_filter"   => description["return filter"],
            "max_depth"       => get_depth(description["depth"])
          }.to_json,
          :headers => json_content_type
        }

        type = get_type(return_type)

        @connection.post(traversal_path(:id => get_id(id), :type => type), options) || Array.new
      end

      private

      def get_order(order)
        case order
          when :breadth, "breadth", "breadth first", "breadthFirst", :wide, "wide"
            "breadth first"
          else
            "depth first"
        end
      end

      def get_uniqueness(uniqueness)
        case uniqueness
          when :nodeglobal, "node global", "nodeglobal", "node_global"
            "node global"
          when :nodepath, "node path", "nodepath", "node_path"
            "node path"
          when :noderecent, "node recent", "noderecent", "node_recent"
            "node recent"
          when :relationshipglobal, "relationship global", "relationshipglobal", "relationship_global"
            "relationship global"
          when :relationshippath, "relationship path", "relationshippath", "relationship_path"
            "relationship path"
          when :relationshiprecent, "relationship recent", "relationshiprecent", "relationship_recent"
            "relationship recent"
          else
            "none"
        end
      end

      def get_depth(depth)
        return nil if depth.nil?
        return 1 if depth.to_i == 0
        depth.to_i
      end

      def get_type(type)
        case type
          when :relationship, "relationship", :relationships, "relationships"
            "relationship"
          when :path, "path", :paths, "paths"
            "path"
          when :fullpath, "fullpath", :fullpaths, "fullpaths"
            "fullpath"
          else
            "node"
        end
      end

    end
  end
end
