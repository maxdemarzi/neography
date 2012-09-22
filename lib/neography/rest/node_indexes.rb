module Neography
  class Rest
    class NodeIndexes < Indexes
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :all,       "/index/node"
      add_path :base,      "/index/node/:index"
      add_path :unique,    "/index/node/:index?unique"
      add_path :id,        "/index/node/:index/:id"
      add_path :key,       "/index/node/:index/:key/:id"
      add_path :value,     "/index/node/:index/:key/:value/:id"
      add_path :key_value, "/index/node/:index/:key/:value"
      add_path :query,     "/index/node/:index?query=:query"

      def initialize(connection)
        super(connection, :node)
      end

      def create_unique(index, key, value, properties = {})
        options = {
          :body => (
            { :properties => properties,
              :key => key,
              :value => value
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(unique_path(:index => index), options)
      end

    end
  end
end
