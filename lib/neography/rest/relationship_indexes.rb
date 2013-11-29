module Neography
  class Rest
    class RelationshipIndexes < Indexes
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :all,       "/index/relationship"
      add_path :base,      "/index/relationship/:index"
      add_path :unique,    "/index/relationship/:index?unique"
      add_path :id,        "/index/relationship/:index/:id"
      add_path :key,       "/index/relationship/:index/:key/:id"
      add_path :value,     "/index/relationship/:index/:key/:value/:id"
      add_path :key_value, "/index/relationship/:index/:key/:value"
      add_path :query,     "/index/relationship/:index?query=:query"

      def initialize(connection)
        super(connection, :relationship)
      end

      def create_unique(index, key, value, type, from, to, props = nil)
        body = {
          :key   => key,
          :value => value,
          :type  => type,
          :start => @connection.configuration + "/node/#{get_id(from)}",
          :end   => @connection.configuration + "/node/#{get_id(to)}",
          :properties => props
        }
        options = { :body => body.to_json, :headers => json_content_type }

        @connection.post(unique_path(:index => index), options)
      end

    end
  end
end
