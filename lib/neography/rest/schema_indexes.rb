module Neography
  class Rest
    class SchemaIndexes
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :base,      "/schema/index/:label"
      add_path :drop,      "/schema/index/:label/:index"

      def initialize(connection)
        @connection ||= connection
      end

      def list(label)
        @connection.get(base_path(:label => label))
      end

      def drop(label, index)
        @connection.delete(drop_path(:label => label, :index => index))
      end

      def create(label, keys = [])
        options = {
          :body => (
            { :property_keys => keys
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(base_path(:label => label), options)
      end
    end
  end
end
