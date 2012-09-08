module Neography
  class Rest
    class RelationshipIndexes
      include Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :all,  "/index/relationship"
      add_path :base, "/index/relationship/:index"
      add_path :unique, "/index/relationship/:index?unique"

      add_path :relationship, "/index/relationship/:index/:id"
      add_path :key,          "/index/relationship/:index/:key/:id"
      add_path :value,        "/index/relationship/:index/:key/:value/:id"
      add_path :key_value,    "/index/relationship/:index/:key/:value"

      add_path :key_query,    "/index/relationship/:index/:key?query=:query"
      add_path :query,        "/index/relationship/:index?query=:query"

      def initialize(connection)
        @connection = connection
      end

      def list
        @connection.get(all)
      end

      def create(name, type, provider)
        options = {
          :body => (
            { :name => name,
              :config => {
                :type => type,
                :provider => provider
              }
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(all, options)
      end

      def create_auto(type, provider)
        create("relationship_auto_index", type, provider)
      end

      def create_unique(index, key, value, type, from, to)
        body = {
          :key   => key,
          :value => value,
          :type  => type,
          :start => @connection.configuration + "/node/#{get_id(from)}",
          :end   => @connection.configuration + "/node/#{get_id(to)}"
        }
        options = { :body => body.to_json, :headers => json_content_type }

        @connection.post(unique(:index => index), options)
      end

      def add(index, key, value, id)
        options = {
          :body => (
            { :uri   => @connection.configuration + "/relationship/#{get_id(id)}",
              :key   => key,
              :value => value
            }
          ).to_json,
          :headers => json_content_type
        }

        @connection.post(base(:index => index), options)
      end

      def get(index, key, value)
        index = @connection.get(key_value(:index => index, :key => key, :value => value)) || Array.new
        return nil if index.empty?
        index
      end

      def find_by_key_query(index, key, query)
        @connection.get(key_query(:index => index, :key => key, :query => query)) || Array.new
      end

      def find_by_query(index, query)
        @connection.get(query(:index => index, :query => query)) || Array.new
      end

      def remove(index, id)
        @connection.delete(relationship(:index => index, :id => get_id(id)))
      end

      def remove_by_key(index, id, key)
        @connection.delete(key(:index => index, :id => get_id(id), :key => key))
      end

      def remove_by_value(index, id, key, value)
        @connection.delete(value(:index => index, :id => get_id(id), :key => key, :value => value))
      end

    end
  end
end
