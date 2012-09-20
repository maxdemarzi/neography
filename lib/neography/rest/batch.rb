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
          send(args[0].to_sym, args)
        else
          raise "Unknown option #{args[0]}"
        end
      end

      def get_node(args)
        {
          :method => "GET",
          :to => Nodes.base_path(:id => get_id(args[1]))
        }
      end

      def create_node(args)
        {
          :method => "POST",
          :to => Nodes.index_path,
          :body => args[1]
        }
      end

      def delete_node(args)
        {
          :method => "DELETE",
          :to => Nodes.base_path(:id => get_id(args[1]))
        }
      end

      def create_unique_node(args)
        {
          :method => "POST",
          :to => NodeIndexes.unique_path(:index => args[1]),
          :body => {
            :key        => args[2],
            :value      => args[3],
            :properties => args[4]
          }
        }
      end

      def add_node_to_index(args)
        {
          :method => "POST",
          :to => "/index/node/#{args[1]}",
          :body => {
            :uri   => build_node_uri(args[4]),
            :key   => args[2],
            :value => args[3]
          }
        }
      end

      def get_node_index(args)
        {
          :method => "GET",
          :to     => "/index/node/#{args[1]}/#{args[2]}/#{args[3]}"
        }
      end

      def remove_node_from_index(args)
        path = case args.size
               when 5
                 NodeIndexes.value_path(:index => args[1], :key => args[2], :value => args[3], :id => get_id(args[4]))
               when 4
                 NodeIndexes.key_path(:index => args[1], :key => args[2], :id => get_id(args[3]))
               when 3
                 NodeIndexes.id_path(:index => args[1], :id => get_id(args[2]))
               end

        {
          :method => "DELETE",
          :to     => path
        }
      end

      def set_node_property(args)
        {
          :method => "PUT",
          :to     => NodeProperties.single_path(:id => get_id(args[1]), :property => args[2].keys.first),
          :body   => args[2].values.first
        }
      end

      def reset_node_properties(args)
        {
          :method => "PUT",
          :to     => NodeProperties.all_path(:id => get_id(args[1])),
          :body   => args[2]
        }
      end

      def get_node_relationships(args)
        {
          :method => "GET",
          :to     => NodeRelationships.direction_path(:id => get_id(args[1]), :direction => args[2] || 'all'),
        }
      end

      def get_relationship(args)
        {
          :method => "GET",
          :to => Relationships.base_path(:id => get_id(args[1]))
        }
      end

      def create_relationship(args)
        {
          :method => "POST",
          :to => build_node_uri(args[2]) + "/relationships",
          :body => {
            :to   => build_node_uri(args[3]),
            :type => args[1],
            :data => args[4]
          }
        }
      end

      def delete_relationship(args)
        {
          :method => "DELETE",
          :to     => Relationships.base_path(:id =>get_id(args[1]))
        }
      end

      def create_unique_relationship(args)
        {
          :method => "POST",
          :to => "/index/relationship/#{args[1]}?unique",
          :body => {
            :key   => args[2],
            :value => args[3],
            :type  => args[4],
            :start => build_node_uri(args[5]),
            :end   => build_node_uri(args[6])
          }
        }
      end

      def add_relationship_to_index(args)
        {
          :method => "POST",
          :to => "/index/relationship/#{args[1]}",
          :body => {
            :uri   => build_relationship_uri(args[4]),
            :key   => args[2],
            :value => args[3]
          }
        }
      end

      def get_relationship_index(args)
        {
          :method => "GET",
          :to     => "/index/relationship/#{args[1]}/#{args[2]}/#{args[3]}"
        }
      end

      def set_relationship_property(args)
        {
          :method => "PUT",
          :to     => RelationshipProperties.single_path(:id => get_id(args[1]), :property => args[2].keys.first),
          :body   => args[2].values.first
        }
      end

      def reset_relationship_properties(args)
        {
          :method => "PUT",
          :to     => build_relationship_uri(args[1]) + "/properties",
          :body   => args[2]
        }
      end

      def execute_query(args)
        request = {
          :method => "POST",
          :to => @connection.cypher_path,
          :body => {
            :query => args[1]
          }
        }

        request[:body].merge!({ :params => args[2] }) if args[2]

        request
      end

      def remove_relationship_from_index(args)
        path = case args.size
               when 5
                 RelationshipIndexes.value_path(:index => args[1], :key => args[2], :value => args[3], :id => get_id(args[4]))
               when 4
                 RelationshipIndexes.key_path(:index => args[1], :key => args[2], :id => get_id(args[3]))
               when 3
                 RelationshipIndexes.id_path(:index => args[1], :id => get_id(args[2]))
               end

        {
          :method => "DELETE",
          :to     => path
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

      def execute_script(args)
        {
          :method => "POST",
          :to => @connection.gremlin_path,
          :body => {
            :script => args[1],
            :params => args[2]
          }
        }
      end

    end
  end
end
