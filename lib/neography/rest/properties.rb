module Neography
  class Rest
    class Properties
      include Neography::Rest::Helpers

      def initialize(connection)
        @connection = connection
      end

      def set(id, properties)
        properties.each do |property, value|
          options = { :body => value.to_json, :headers => json_content_type }
          @connection.put(single_path(:id => get_id(id), :property => property), options)
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
        retrieved_properties = properties.flatten.inject({}) do |memo, property|
          value = @connection.get(single_path(:id => get_id(id), :property => property))
          memo[property] = value unless value.nil?
          memo
        end
        return nil if retrieved_properties.empty?
        retrieved_properties
      end

      def remove(id, *properties)
        if properties.none?
          @connection.delete(all_path(:id => get_id(id)))
        else
          remove_each(id, *properties)
        end
      end

      def remove_each(id, *properties)
        properties.flatten.each do |property|
          @connection.delete(single_path(:id => get_id(id), :property => property))
        end
      end

    end
  end
end
