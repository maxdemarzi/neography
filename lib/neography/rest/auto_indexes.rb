module Neography
  class Rest
    class AutoIndexes
      include Neography::Rest::Helpers

      def initialize(connection)
        @connection ||= connection
      end

      def get(key, value)
        index = @connection.get(key_value_path(:key => key, :value => value)) || []
        return nil if index.empty?
        index
      end

      def find_or_query(key_or_query, value = nil)
        if value
          index = find(key_or_query, value)
        else
          index = query(key_or_query)
        end
        return nil if index.empty?
        index
      end

      def find(key, value)
        @connection.get(key_value_path(:key => key, :value => value)) || []
      end

      def query(query_expression)
        @connection.get(query_index_path(:query => query_expression)) || []
      end

      def status
        @connection.get(index_status_path)
      end

      def status=(value)
        options = {
          :body => value.to_json,
          :headers => json_content_type
        }
        @connection.put(index_status_path, options)
      end

      def properties
        @connection.get(index_properties_path)
      end

      def add_property(property)
        options = {
          :body => property,
          :headers => json_content_type
        }
        @connection.post(index_properties_path, options)
      end

      def remove_property(property)
        @connection.delete(index_property_path(:property => property))
      end

    end
  end
end
