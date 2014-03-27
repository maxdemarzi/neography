module Neography
  class Rest
    module RelationshipAutoIndexes 
    
      def get_relationship_auto_index(key, value)
        index = @connection.get("/index/auto/relationship/%{key}/%{value}" % {:key => key, :value => encode(value)}) || []
        return nil if index.empty?
        index
      end

      def find_relationship_auto_index(key_or_query, value = nil)
        if value
          index = find_relationship_auto_index_by_value(key_or_query, value)
        else
          index = query_relationship_auto_index(key_or_query)
        end
        return nil if index.empty?
        index
      end

      def find_relationship_auto_index_by_value(key, value)
        @connection.get("/index/auto/relationship/%{key}/%{value}" % {:key => key, :value => encode(value)}) || []
      end

      def query_relationship_auto_index(query_expression)
        @connection.get("/index/auto/relationship/?query=%{query}" % {:query => query_expression}) || []
      end

      def get_relationship_auto_index_status
        @connection.get("/index/auto/relationship/status")
      end

      def set_relationship_auto_index_status(value = true)
        options = {
          :body => value.to_json,
          :headers => json_content_type
        }
        @connection.put("/index/auto/relationship/status", options)
      end

      def get_relationship_auto_index_properties
        @connection.get("/index/auto/relationship/properties")
      end

      def add_relationship_auto_index_property(property)
        options = {
          :body => property,
          :headers => json_content_type
        }
        @connection.post("/index/auto/relationship/properties", options)
      end

      def remove_relationship_auto_index_property(property)
        @connection.delete("/index/auto/relationship/properties/%{property}" % {:property => property})
      end


    end
  end
end
