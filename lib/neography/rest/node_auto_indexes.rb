module Neography
  class Rest
    module NodeAutoIndexes 
    
      def get_node_auto_index(key, value)
        index = @connection.get("/index/auto/node/%{key}/%{value}" % {:key => key, :value => encode(value)}) || []
        return nil if index.empty?
        index
      end

      def find_node_auto_index(key_or_query, value = nil)
        if value
          index = find_node_auto_index_by_value(key_or_query, value)
        else
          index = query_node_auto_index(key_or_query)
        end
        return nil if index.empty?
        index
      end

      def find_node_auto_index_by_value(key, value)
        @connection.get("/index/auto/node/%{key}/%{value}" % {:key => key, :value => encode(value)}) || []
      end

      def query_node_auto_index(query_expression)
        @connection.get("/index/auto/node/?query=%{query}" % {:query => encode(query_expression)}) || []
      end

      def get_node_auto_index_status
        @connection.get("/index/auto/node/status")
      end

      def set_node_auto_index_status(value = true)
        options = {
          :body => value.to_json,
          :headers => json_content_type
        }
        @connection.put("/index/auto/node/status", options)
      end

      def get_node_auto_index_properties
        @connection.get("/index/auto/node/properties")
      end

      def add_node_auto_index_property(property)
        options = {
          :body => property,
          :headers => json_content_type
        }
        @connection.post("/index/auto/node/properties", options)
      end

      def remove_node_auto_index_property(property)
        @connection.delete("/index/auto/node/properties/%{property}" % {:property => property})
      end


    end
  end
end
