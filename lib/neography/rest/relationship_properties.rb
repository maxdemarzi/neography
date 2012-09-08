module Neography
  class Rest
    class RelationshipProperties
      include Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :all,    "/relationship/:id/properties"
      add_path :single, "/relationship/:id/properties/:property"

      def initialize(connection)
        @connection = connection
      end

      def set(id, properties)
        properties.each do |key, value|
          options = { :body => value.to_json, :headers => json_content_type }
          @connection.put(single_path(:id => get_id(id), :property => key), options)
        end
      end

      def reset(id, properties)
        options = { :body => properties.to_json, :headers => json_content_type }
        @connection.put(all_path(:id => get_id(id)), options)
      end

      def get(id, *properties)
        if properties.none?
          @connection.get(all_path(:id => get_id(id)))
        else
          get_each(id, *properties)
        end
      end

      def get_each(id, *properties)
        relationship_properties = properties.inject({}) do |memo, property|
          value = @connection.get(single_path(:id => get_id(id), :property => property))
          memo[property] = value unless value.nil?
          memo
        end
        return nil if relationship_properties.empty?
        relationship_properties
      end

      def remove(id, *properties)
        if properties.none?
          @connection.delete(all_path(:id => get_id(id)))
        else
          remove_each(id, *properties)
        end
      end

      def remove_each(id, *properties)
        properties.each do |property|
          @connection.delete(single_path(:id => get_id(id), :property => property))
        end
      end

    end
  end
end
