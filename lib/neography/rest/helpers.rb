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

    end
  end
end
