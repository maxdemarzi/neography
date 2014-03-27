module Neography
  class Rest
    module Helpers

      def get_id(id)
        case id
        when Array
          get_id(id.first)
        when Hash
          id["self"].split('/').last
        when String
          id.split('/').last
        when Neography::Node, Neography::Relationship
          id.neo_id
        else
          id
        end
      end

      def json_content_type
        {'Content-Type' => 'application/json'}
      end

      def parse_direction(direction)
        case direction
          when :incoming, "incoming", :in, "in"
            "in"
          when :outgoing, "outgoing", :out, "out"
            "out"
          else
            "all"
        end
      end

      def encode(value)
        CGI.escape(value.to_s).gsub("+", "%20")
      end
      
      def escape(value)
        if value.class == String
          "%22"+encode(value.to_s)+"%22";
        else
          encode(value.to_s)
        end
      end
      
      def parse_order(order)
        case order
          when :breadth, "breadth", "breadth first", "breadthFirst", :wide, "wide"
            "breadth first"
          else
            "depth first"
        end
      end

      def parse_uniqueness(uniqueness)
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

      def parse_depth(depth)
        return nil if depth.nil?
        return 1 if depth.to_i == 0
        depth.to_i
      end

      def parse_type(type)
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
