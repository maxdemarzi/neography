module Neography
  class Rest
    module SchemaIndexes
      include Neography::Rest::Helpers
        
      def get_schema_index(label)
        @connection.get("/schema/index/%{label}" % {:label => label})
      end

      def delete_schema_index(label, index)
        @connection.delete("/schema/index/%{label}/%{index}" % {:label => label, :index => index})
      end

      def create_schema_index(label, keys = [])
        options = {
          :body => (
            { :property_keys => keys
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post("/schema/index/%{label}" % {:label => label}, options)
      end
    end
  end
end
