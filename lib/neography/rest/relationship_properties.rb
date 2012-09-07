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

      def get(id, properties)
        if properties.nil?
          @connection.get(all(:id => get_id(id)))
        else
          relationship_properties = Hash.new
          Array(properties).each do |property|
            value = @connection.get(single(:id => get_id(id), :property => property))
            relationship_properties[property] = value unless value.nil?
          end
          return nil if relationship_properties.empty?
          relationship_properties
        end
      end

      def reset(id, properties)
        options = { :body => properties.to_json, :headers => json_content_type }
        @connection.put(all(:id => get_id(id)), options)
      end

      def remove(id, properties)
        if properties.nil?
          @connection.delete(all(id: get_id(id)))
        else
          Array(properties).each do |property|
            @connection.delete(single(:id => get_id(id), :property => property))
          end
        end
      end

      def set(id, properties)
        properties.each do |key, value|
          options = { :body => value.to_json, :headers => json_content_type }
          @connection.put(single(:id => get_id(id), :property => key), options)
        end
      end

    end
  end
end
