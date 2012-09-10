module Neography
  class Rest
    class Indexes
      include Neography::Rest::Helpers

      def initialize(connection, index_type)
        @connection = connection
        @index_type = index_type
      end

      def list
        @connection.get(all_path)
      end

      def create(name, type = "exact", provider = "lucene")
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

      def create_auto(type = "exact", provider = "lucene")
        create("#{@index_type}_auto_index", type, provider)
      end

      def add(index, key, value, id)
        options = {
          :body => (
            { :uri   => @connection.configuration + "/#{@index_type}/#{get_id(id)}",
              :key   => key,
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

      def find(index, key_or_query, value = nil)
        if value
          index = find_by_key_value(index, key_or_query, value)
        else
          index = find_by_query(index, key_or_query)
        end
        return nil if index.empty?
        index
      end

      def find_by_key_value(index, key, value)
        @connection.get(key_value_path(:index => index, :key => key, :value => value)) || []
      end

      def find_by_query(index, query)
        @connection.get(query_path(:index => index, :query => query)) || []
      end

      # Mimick original neography API in Rest class.
      def remove(index, id_or_key, id_or_value = nil, id = nil)
        if id
          remove_by_value(index, id, id_or_key, id_or_value)
        elsif id_or_value
          remove_by_key(index, id_or_value, id_or_key)
        else
          remove_by_id(index, id_or_key)
        end
      end

      def remove_by_id(index, id)
        @connection.delete(id_path(:index => index, :id => get_id(id)))
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
