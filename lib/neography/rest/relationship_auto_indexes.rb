module Neography
  class Rest
    class RelationshipAutoIndexes
      include Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :key_value,        "/index/auto/relationship/:key/:value"
      add_path :query_index,      "/index/auto/relationship/?query=:query"
      add_path :index_status,     "/index/auto/relationship/status"
      add_path :index_properties, "/index/auto/relationship/properties"
      add_path :index_property,   "/index/auto/relationship/properties/:property"

      def initialize(connection)
        @connection = connection
      end

      def get(key, value)
        index = @connection.get(key_value_path(:key => key, :value => value)) || Array.new
        return nil if index.empty?
        index
      end

      def find(key, value)
        @connection.get(key_value_path(:key => key, :value => value)) || Array.new
      end

      def query(query_expression)
        @connection.get(query_index_path(:query => query_expression)) || Array.new
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
