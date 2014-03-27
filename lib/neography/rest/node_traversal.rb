module Neography
  class Rest
    module NodeTraversal
      include Neography::Rest::Helpers
    
      def traverse(id, return_type, description)
        options = { :body => {
            "order"           => parse_order(description["order"]),
            "uniqueness"      => parse_uniqueness(description["uniqueness"]),
            "relationships"   => description["relationships"],
            "prune_evaluator" => description["prune evaluator"],
            "return_filter"   => description["return filter"],
            "max_depth"       => parse_depth(description["depth"])
          }.to_json,
          :headers => json_content_type
        }

        type = parse_type(return_type)

        @connection.post("/node/%{id}/traverse/%{type}" % {:id => get_id(id), :type => type}, options) || []
      end

    end
  end
end
