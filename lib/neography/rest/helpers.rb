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

    end
  end
end
