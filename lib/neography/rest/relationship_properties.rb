module Neography
  class Rest
    module RelationshipProperties
    
      def set_relationship_properties(id, properties)
        properties.each do |property, value|
          options = { :body => value.to_json, :headers => json_content_type }
          @connection.put("/relationship/%{id}/properties/%{property}" % {:id => get_id(id), :property => property}, options)
        end
      end

      def reset_relationship_properties(id, properties)
        options = { :body => properties.to_json, :headers => json_content_type }
        @connection.put("/relationship/%{id}/properties" % {:id => get_id(id)}, options)
      end

      def get_relationship_properties(id, *properties)
        if properties.none?
          @connection.get("/relationship/%{id}/properties" % {:id => get_id(id)})
        else
          get_each_relationship_properties(id, *properties)
        end
      end

      def get_each_relationship_properties(id, *properties)
        retrieved_properties = properties.flatten.inject({}) do |memo, property|
          value = @connection.get("/relationship/%{id}/properties/%{property}" % {:id => get_id(id), :property => property})
          memo[property] = value unless value.nil?
          memo
        end
        return nil if retrieved_properties.empty?
        retrieved_properties
      end

      def remove_relationship_properties(id, *properties)
        if properties.none?
          @connection.delete("/relationship/%{id}/properties" % {:id => get_id(id)})
        else
          remove_each_relationship_properties(id, *properties)
        end
      end

      def remove_each_relationship_properties(id, *properties)
        properties.flatten.each do |property|
          @connection.delete("/relationship/%{id}/properties/%{property}" % {:id => get_id(id), :property => property})
        end
      end


    end
  end
end
