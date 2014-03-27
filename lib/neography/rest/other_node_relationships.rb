module Neography
  class Rest
    module OtherNodeRelationships
      include Neography::Rest::Helpers
    
      def get_node_relationships_to(id, other_id, direction = "all", types = [nil] )
        
        body = case parse_direction(direction)
                 when "all"
                   "position.endNode().getId() == " + get_id(other_id)
                 when "in"
                   "position.length() > 0 && position.lastRelationship().getStartNode().getId() == " + get_id(other_id)
                 when "out"
                   "position.length() > 0 && position.lastRelationship().getEndNode().getId() == " + get_id(other_id) 
                end

        relationships = {:relationships => Array(types).map{|row| Hash[{:type => row}].merge({:direction => parse_direction(direction)})} }

        if Array(types).first.nil?
          relationships = {}
        end
                
        options = {
          :body => {:order      => "breadth_first",
                    :uniqueness => "relationship_global",
                    :max_depth  => 1,
                    :return_filter => {:language => "javascript",
                                       :body =>  body }
                    }.merge(relationships).to_json,
          :headers => json_content_type
        }

        @connection.post("/node/%{id}/traverse/relationship" % {:id => get_id(id)}, options) || []
      end

    end
  end
end
