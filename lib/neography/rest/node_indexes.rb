module Neography
  class Rest
    class NodeIndexes
      include Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :all,       "/index/node"
      add_path :base,      "/index/node/:index"
      add_path :unique,    "/index/node/:index?unique"
      add_path :node,      "/index/node/:index/:id"
      add_path :key,       "/index/node/:index/:key/:id"
      add_path :value,     "/index/node/:index/:key/:value/:id"
      add_path :key_value, "/index/node/:index/:key/:value"
      add_path :query,     "/index/node/:index?query=:query"

      add_path :key_value2, "/index/node/:index/:key?query=\":value\"" # TODO FIX BUG %20

      def initialize(connection)
        @connection = connection
      end

      def list
        @connection.get(all_path)
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
        @connection.post(all_path, options)
      end

      def create_auto(type, provider)
        create("node_auto_index", type, provider)
      end

      def create_unique(index, key, value, props)
        options = {
          :body => (
            { :properties => props,
              :key => key,
              :value => value
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(unique_path(:index => index), options)
      end

      def add(index, key, value, id)
        options = {
          :body => (
            { :uri => @connection.configuration + "/node/#{get_id(id)}",
              :key => key,
              :value => value
            }
          ).to_json,
          :headers => json_content_type
        }
        @connection.post(base_path(:index => index), options)
      end

      def get(index, key, value)
        index = @connection.get(key_value_path(:index => index, :key => key, :value => value)) || []
        return nil if index.empty?
        index
      end

      # TODO FIX BUG %20
      def find_by_value(index, key, value)
        @connection.get(key_value2_path(:index => index, :key => key, :value => value)) || []
      end

      def find_by_query(index, query)
        @connection.get(query_path(:index => index, :query => query)) || []
      end

      def remove(index, id)
        @connection.delete(node_path(:index => index, :id => get_id(id)))
      end

      def remove_by_key(index, id, key)
        @connection.delete(key_path(:index => index, :id => get_id(id), :key => key))
      end

      def remove_by_value(index, id, key, value)
        @connection.delete(value_path(:index => index, :id => get_id(id), :key => key, :value => value))
      end

    end
  end
end
