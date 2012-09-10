module Neography
  class Rest
    class NodeRelationships
      include Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :base,       "/node/:id/relationships"
      add_path :direction,  "/node/:id/relationships/:direction"
      add_path :type,       "/node/:id/relationships/:direction/:types"

      def initialize(connection)
        @connection = connection
      end

      def create(type, from, to, properties = nil)
        options = {
          :body => {
            :to => @connection.configuration + "/node/#{get_id(to)}",
            :data => properties,
            :type => type
          }.to_json,
          :headers => json_content_type }

        @connection.post(base_path(:id => get_id(from)), options)
      end

      def get(id, direction = nil, types = nil)
        direction = parse_direction(direction)

        if types.nil?
          node_relationships = @connection.get(direction_path(:id => get_id(id), :direction => direction)) || []
        else
          node_relationships = @connection.get(type_path(:id => get_id(id), :direction => direction, :types => Array(types).join('&'))) || []
        end

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
