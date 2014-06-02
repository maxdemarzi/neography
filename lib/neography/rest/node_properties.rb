module Neography
  class Rest
    module NodeProperties

      def set_node_properties(id, properties)
        properties.each do |property, value|
          options = { :body => value.to_json, :headers => json_content_type }
          @connection.put("/node/%{id}/properties/%{property}" % {:id => get_id(id), :property => property}, options)
        end
      end

      def reset_node_properties(id, properties)
        options = { :body => properties.to_json, :headers => json_content_type }
        @connection.put("/node/%{id}/properties" % {:id => get_id(id)}, options)
      end

      def get_node_properties(id, *properties)
        if properties.none?
          @connection.get("/node/%{id}/properties" % {:id => get_id(id)})
        else
          get_each_node_properties(id, *properties)
        end
      end

      def get_each_node_properties(id, *properties)
        retrieved_properties = properties.flatten.inject({}) do |memo, property|
          value = @connection.get("/node/%{id}/properties/%{property}" % {:id => get_id(id), :property => property})
          memo[property] = value unless value.nil?
          memo
        end
        return nil if retrieved_properties.empty?
        retrieved_properties
      end

      def remove_node_properties(id, *properties)
        if properties.none?
          @connection.delete("/node/%{id}/properties" % {:id => get_id(id)})
        else
          remove_each_node_properties(id, *properties)
        end
      end

      def remove_each_node_properties(id, *properties)
        properties.flatten.each do |property|
          @connection.delete("/node/%{id}/properties/%{property}" % {:id => get_id(id), :property => property})
        end
      end


    end
  end
end
