module Neography
  class Rest
    class Batch
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :batch, "/batch"

      def initialize(connection)
        @connection ||= connection
      end

      def execute(*args)
        batch(*args)
      end

      private

      def batch(*args)
        batch = []
        Array(args).each_with_index do |c, i|
          batch << {:id => i }.merge(get_batch(c))
        end
        options = {
          :body => batch.to_json,
          :headers => json_content_type
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

      # Nodes

      def get_node(id)
        get "/node/%{id}" % {:id => get_id(id)}
      end

      def delete_node(id)
        delete "/node/%{id}" % {:id => get_id(id)}
      end

      def create_node(body)
        post "/node" do
          body
        end
      end

      # NodeIndexes

      def create_node_index(name, type = "exact", provider = "lucene", extra_config = nil)
        config = {
          :type => type,
          :provider => provider
        }
        config.merge!(extra_config) unless extra_config.nil?
        post NodeIndexes.all_path do
          { :name => name,
            :config => config
          }
        end
      end

      def drop_node_index(index)
        delete NodeIndexes.unique_path(:index => index)
      end

      def create_unique_node(index, key, value, properties)
        post NodeIndexes.unique_path(:index => index) do
          {
            :key        => key,
            :value      => value,
            :properties => properties
          }
        end
      end

      def add_node_to_index(index, key, value, id, unique = false)
        path = unique ? NodeIndexes.unique_path(:index => index) : NodeIndexes.base_path(:index => index)
        post path do
          {
            :uri   => build_node_uri(id),
            :key   => key,
            :value => value
          }
        end
      end

      def get_node_index(index, key, value)
        get NodeIndexes.key_value_path(:index => index, :key => key, :value => value)
      end

      def remove_node_from_index(index, key_or_id, value_or_id = nil, id = nil)
        delete remove_from_index_path(NodeIndexes, index, key_or_id, value_or_id, id)
      end

      # NodeProperties

      def set_node_property(id, property)
        put "/node/%{id}/properties/%{property}" % {:id => get_id(id), :property => property.keys.first} do
          property.values.first
        end
      end

      def reset_node_properties(id, body)
        put "/node/%{id}/properties" % {:id => get_id(id)} do
          body
        end
      end

      def remove_node_property(id, property)
        delete "/node/%{id}/properties/%{property}" % {:id => get_id(id), :property => property}
      end

      # NodeLabel

      def add_label(id, body)
        post build_node_uri(id) + "/labels" do
          body
        end
      end

      # NodeRelationships

      def get_node_relationships(id, direction = nil, types = nil)
        if types.nil?
          get NodeRelationships.direction_path(:id => get_id(id), :direction => direction || 'all')
        else
          get NodeRelationships.type_path(:id => get_id(id), :direction => direction, :types => Array(types).join('&'))
        end
      end

      # Relationships

      def get_relationship(id)
        get Relationships.base_path(:id => get_id(id))
      end

      def delete_relationship(id)
        delete Relationships.base_path(:id => get_id(id))
      end

      def create_relationship(type, from, to, data = nil)
        post build_node_uri(from) + "/relationships" do
          {
            :to   => build_node_uri(to),
            :type => type,
            :data => data
          }
        end
      end

      # RelationshipIndexes

      def create_unique_relationship(index, key, value, type, from, to, props = nil)
        post RelationshipIndexes.unique_path(:index => index) do
          {
            :key   => key,
            :value => value,
            :type  => type,
            :start => build_node_uri(from),
            :end   => build_node_uri(to),
            :properties => props
          }
        end
      end

      def add_relationship_to_index(index, key, value, id)
        post RelationshipIndexes.base_path(:index => index) do
          {
            :uri   => build_relationship_uri(id),
            :key   => key,
            :value => value
          }
        end
      end

      def get_relationship_index(index, key, value)
        get RelationshipIndexes.key_value_path(:index => index, :key => key, :value => value)
      end

      def remove_relationship_from_index(index, key_or_id, value_or_id = nil, id = nil)
        delete remove_from_index_path(RelationshipIndexes, index, key_or_id, value_or_id, id)
      end

      # RelationshipProperties

      def set_relationship_property(id, property)
        put RelationshipProperties.single_path(:id => get_id(id), :property => property.keys.first) do
          property.values.first
        end
      end

      def reset_relationship_properties(id, body)
        put build_relationship_uri(id) + "/properties" do
          body
        end
      end

      # Cypher

      def execute_query(query, params = nil)
        request = post @connection.cypher_path do
          {
            :query => query
          }
        end

        request[:body].merge!({ :params => params }) if params

        request
      end

      # Gremlin

      def execute_script(script, params = nil)
        post @connection.gremlin_path do
          {
            :script => script,
            :params => params
          }
        end
      end

      # Similar between nodes and relationships

      def remove_from_index_path(klass, index, key_or_id, value_or_id = nil, id = nil)
        if id
          klass.value_path(:index => index, :key => key_or_id, :value => value_or_id, :id => get_id(id))
        elsif value_or_id
          klass.key_path(:index => index, :key => key_or_id, :id => get_id(value_or_id))
        else
          klass.id_path(:index => index, :id => get_id(key_or_id))
        end
      end

      # Spatial
      
      def get_spatial
        get Spatial.index_path
      end
    
      def add_point_layer(layer, lat = nil, lon = nil)
         post Spatial.add_simple_point_layer_path do
          {
              :layer => layer,
              :lat => lat || "lat",
              :lon => lon || "lon"
            }
          end
      end

      def add_editable_layer(layer, format = "WKT", node_property_name = "wkt")
        post Spatial.add_editable_layer_path do 
          {
              :layer => layer,
              :format => format,
              :nodePropertyName => node_property_name
            }
        end
      end

      def get_layer(layer)
        post Spatial.get_layer_path do
          {
              :layer => layer
            }
        end
      end

      def add_geometry_to_layer(layer, geometry)
        post Spatial.add_geometry_to_layer_path do 
          {
              :layer => layer,
              :geometry => geometry
            }
        end
      end
    
      def edit_geometry_from_layer(layer, geometry, node)
        post Spatial.edit_geometry_from_layer_path do 
          {
              :layer => layer,
              :geometry => geometry,
              :geometryNodeId => get_id(node)
            }
        end
      end
    
      def add_node_to_layer(layer, node)
        post Spatial.add_node_to_layer_path do 
          {
              :layer => layer,
              :node => get_id(node)
            }
        end
      end
    
      def find_geometries_in_bbox(layer, minx, maxx, miny, maxy)
        post Spatial.find_geometries_in_bbox_path do 
          {
              :layer => layer,
              :minx => minx,
              :maxx => maxx,
              :miny => miny,
              :maxy => maxy
            }
        end
      end
    
      def find_geometries_within_distance(layer, pointx, pointy, distance)
        post Spatial.find_geometries_within_distance_path do 
          {
              :layer => layer,
              :pointX => pointx,
              :pointY => pointy,
              :distanceInKm => distance
            }
        end
      end
      
      def create_spatial_index(name, type, lat, lon)
        post NodeIndexes.all_path do
          {
            :name => name,
            :config => {
              :provider => "spatial",
              :geometry_type => type || "point",
              :lat => lat || "lat",
              :lon => lon || "lon"
              }
          }
        end
      end

      def add_node_to_spatial_index(index, id)
        post NodeIndexes.base_path(:index => index) do
          {
            :uri   => build_node_uri(id),
            :key   => "k",
            :value => "v"
          }
        end
      end

      def get(to, &block)
        request "GET", to, &block
      end

      def delete(to, &block)
        request "DELETE", to, &block
      end

      def post(to, &block)
        request "POST", to, &block
      end

      def put(to, &block)
        request "PUT", to, &block
      end

      def request(method, to, &block)
        request = {
          :method => method,
          :to     => to
        }
        request.merge!({ :body => yield }) if block_given?
        request
      end

      # Helper methods

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
