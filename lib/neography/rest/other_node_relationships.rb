module Neography
  class Rest
    class OtherNodeRelationships
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :base,       "/node/:id/traverse/relationship"

      def initialize(connection)
        @connection = connection
      end

      def get(id, other_id, direction = "all", types = [nil])
        
        body = case parse_direction(direction)
                 when "all"
                   "position.endNode().getId() == " + get_id(other_id)
                 when "in"
                   "position.length() > 0 && position.lastRelationship().getStartNode().getId() == " + get_id(other_id)
                 when "out"
                   "position.length() > 0 && position.lastRelationship().getEndNode().getId() == " + get_id(other_id) 
                end

        relationships = {:relationships => types.map{|row| Hash[{:type => row}].merge({:direction => parse_direction(direction)})} }

        if types.first.nil?
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
        #puts options.inspect
        node_relationships = @connection.post(base_path(:id => get_id(id)), options) || []

        return nil if node_relationships.empty?
        node_relationships
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

    end
  end
end
