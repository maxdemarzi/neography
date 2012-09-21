module Neography
  class Rest
    class Batch
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :batch, "/batch"

      def initialize(connection)
        @connection = connection
      end

      def execute(*args)
        batch({'Accept' => 'application/json;stream=true'}, *args)
      end

      def not_streaming(*args)
        batch({}, *args)
      end

      private

      def batch(accept_header, *args)
        batch = []
        Array(args).each_with_index do |c, i|
          batch << {:id => i }.merge(get_batch(c))
        end
        options = {
          :body => batch.to_json,
          :headers => json_content_type.merge(accept_header)
        }

        @connection.post(batch_path, options)
      end

      def get_batch(args)
        if respond_to?(args[0].to_sym, true)
          send(args[0].to_sym, *args[1..-1])
        else
          raise "Unknown option #{args[0]}"
        end
      end

      def get_node(id)
        {
          :method => "GET",
          :to     => Nodes.base_path(:id => get_id(id))
        }
      end

      def create_node(body)
        {
          :method => "POST",
          :to     => Nodes.index_path,
          :body   => body
        }
      end

      def delete_node(id)
        {
          :method => "DELETE",
          :to     => Nodes.base_path(:id => get_id(id))
        }
      end

      def create_unique_node(index, key, value, properties)
        {
          :method => "POST",
          :to     => NodeIndexes.unique_path(:index => index),
          :body   => {
            :key        => key,
            :value      => value,
            :properties => properties
          }
        }
      end

      def add_node_to_index(index, key, value, to)
        {
          :method => "POST",
          :to     => NodeIndexes.base_path(:index => index),
          :body   => {
            :uri   => build_node_uri(to),
            :key   => key,
            :value => value
          }
        }
      end

      def get_node_index(index, key, value)
        {
          :method => "GET",
          :to     => NodeIndexes.key_value_path(:index => index, :key => key, :value => value)
        }
      end

      def remove_node_from_index(index, key_or_id, value_or_id = nil, id = nil)
        {
          :method => "DELETE",
          :to     => remove_node_from_index_path(index, key_or_id, value_or_id, id)
        }
      end

      def remove_node_from_index_path(index, key_or_id, value_or_id = nil, id = nil)
        if id
          NodeIndexes.value_path(:index => index, :key => key_or_id, :value => value_or_id, :id => get_id(id))
        elsif value_or_id
          NodeIndexes.key_path(:index => index, :key => key_or_id, :id => get_id(value_or_id))
        else
          NodeIndexes.id_path(:index => index, :id => get_id(key_or_id))
        end
      end

      def set_node_property(id, property)
        {
          :method => "PUT",
          :to     => NodeProperties.single_path(:id => get_id(id), :property => property.keys.first),
          :body   => property.values.first
        }
      end

      def reset_node_properties(id, body)
        {
          :method => "PUT",
          :to     => NodeProperties.all_path(:id => get_id(id)),
          :body   => body
        }
      end

      def get_node_relationships(id, direction = nil)
        {
          :method => "GET",
          :to     => NodeRelationships.direction_path(:id => get_id(id), :direction => direction || 'all'),
        }
      end

      def get_relationship(id)
        {
          :method => "GET",
          :to     => Relationships.base_path(:id => get_id(id))
        }
      end

      def create_relationship(type, from, to, data)
        {
          :method => "POST",
          :to     => build_node_uri(from) + "/relationships",
          :body   => {
            :to   => build_node_uri(to),
            :type => type,
            :data => data
          }
        }
      end

      def delete_relationship(id)
        {
          :method => "DELETE",
          :to     => Relationships.base_path(:id =>get_id(id))
        }
      end

      def create_unique_relationship(index, key, value, type, from, to)
        {
          :method => "POST",
          :to     => RelationshipIndexes.unique_path(:index => index),
          :body   => {
            :key   => key,
            :value => value,
            :type  => type,
            :start => build_node_uri(from),
            :end   => build_node_uri(to)
          }
        }
      end

      def add_relationship_to_index(index, key, value, id)
        {
          :method => "POST",
          :to     => RelationshipIndexes.base_path(:index => index),
          :body   => {
            :uri   => build_relationship_uri(id),
            :key   => key,
            :value => value
          }
        }
      end

      def get_relationship_index(index, key, value)
        {
          :method => "GET",
          :to     => RelationshipIndexes.key_value_path(:index => index, :key => key, :value => value)
        }
      end

      def set_relationship_property(id, property)
        {
          :method => "PUT",
          :to     => RelationshipProperties.single_path(:id => get_id(id), :property => property.keys.first),
          :body   => property.values.first
        }
      end

      def reset_relationship_properties(id, body)
        {
          :method => "PUT",
          :to     => build_relationship_uri(id) + "/properties",
          :body   => body
        }
      end

      def remove_relationship_from_index(index, key_or_id, value_or_id = nil, id = nil)

        {
          :method => "DELETE",
          :to     => remove_relationship_from_index_path(index, key_or_id, value_or_id, id)
        }
      end

      def remove_relationship_from_index_path(index, key_or_id, value_or_id = nil, id = nil)
         if id
           RelationshipIndexes.value_path(:index => index, :key => key_or_id, :value => value_or_id, :id => get_id(id))
         elsif value_or_id
           RelationshipIndexes.key_path(:index => index, :key => key_or_id, :id => get_id(value_or_id))
         else
           RelationshipIndexes.id_path(:index => index, :id => get_id(key_or_id))
         end
      end

      def execute_query(query, params = nil)
        request = {
          :method => "POST",
          :to     => @connection.cypher_path,
          :body   => {
            :query => query
          }
        }

        request[:body].merge!({ :params => params }) if params

        request
      end

      def execute_script(script, params = nil)
        {
          :method => "POST",
          :to => @connection.gremlin_path,
          :body => {
            :script => script,
            :params => params
          }
        }
      end

      def build_node_uri(value)
        build_uri(value, "node")
      end

      def build_relationship_uri(value)
        build_uri(value, "relationship")
      end

      def build_uri(value, type)
        path_or_variable(value, type) + "#{get_id(value)}"
      end

      def path_or_variable(value, type)
        if value.is_a?(String) && value.start_with?("{")
          ""
        else
          "/#{type}/"
        end
      end

    end
  end
end
