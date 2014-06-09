module Neography
  class Rest
    module Batch
      include Neography::Rest::Helpers
    
      def batch(*args)
        do_batch(*args)
      end

      def batch_no_streaming(*args)
        do_batch_no_streaming(*args)
      end

      private

      def do_batch(*args)
        @connection.post("/batch", compute_batch_options(*args))
      end

      def do_batch_no_streaming(*args)
        options = compute_batch_options(*args)
        options[:headers].merge!({ 'X-Stream' => false })
        @connection.post("/batch", options)
      end

      def compute_batch_options(*args)
        batch = []
        Array(args).each_with_index do |c, i|
          batch << {:id => i }.merge(get_batch(c))
        end
        {:body => batch.to_json, :headers => json_content_type}
      end

      def get_batch(args)
        begin
          send("batch_#{args[0]}".to_sym, *args[1..-1])
        rescue
          raise UnknownBatchOptionException.new("Unknown option #{args[0]} - #{args}")
        end
      end

      # Nodes

      def batch_get_node(id)
        get "/node/%{id}" % {:id => get_id(id)}
      end

      def batch_delete_node(id)
        delete "/node/%{id}" % {:id => get_id(id)}
      end

      def batch_create_node(body)
        post "/node" do
          body
        end
      end

      # NodeIndexes

      def batch_create_node_index(name, type = "exact", provider = "lucene", extra_config = nil)
        config = {
          :type => type,
          :provider => provider
        }
        config.merge!(extra_config) unless extra_config.nil?
        post "/index/node" do
          { :name => name,
            :config => config
          }
        end
      end

      def batch_drop_node_index(index)
        delete "/index/node/%{index}?unique" % {:index => index}
      end

      def batch_create_unique_node(index, key, value, properties)
        post "/index/node/%{index}?unique" % {:index => index} do
          {
            :key        => key,
            :value      => value,
            :properties => properties
          }
        end
      end
      
      def batch_create_or_fail_unique_node(index, key, value, properties = {})
        post "/index/node/%{index}?uniqueness=%{function}" %  {:index => index, :function => 'create_or_fail'} do
          {
            :key        => key,
            :value      => value,
            :properties => properties
          }
        end
      end

      def batch_add_node_to_index(index, key, value, id, unique = false)
        path = unique ? "/index/node/%{index}?unique" % {:index => index} : "/index/node/%{index}" % {:index => index}
        post path do
          {
            :uri   => build_node_uri(id),
            :key   => key,
            :value => value
          }
        end
      end

      def batch_get_node_index(index, key, value)
        get "/index/node/%{index}/%{key}/%{value}" % {:index => index, :key => key, :value => encode(value)}
      end

      def batch_remove_node_from_index(index, key_or_id, value_or_id = nil, id = nil)
        delete remove_from_index_path("node", index, key_or_id, value_or_id, id)
      end

      # NodeProperties

      def batch_set_node_property(id, property)
        put "/node/%{id}/properties/%{property}" % {:id => get_id(id), :property => property.keys.first} do
          property.values.first
        end
      end

      def batch_reset_node_properties(id, body)
        put "/node/%{id}/properties" % {:id => get_id(id)} do
          body
        end
      end

      def batch_remove_node_property(id, property)
        delete "/node/%{id}/properties/%{property}" % {:id => get_id(id), :property => property}
      end

      # NodeLabel

      def batch_add_label(id, body)
        post build_node_uri(id) + "/labels" do
          body
        end
      end

      # NodeRelationships

      def batch_get_node_relationships(id, direction = nil, types = nil)
        if types.nil?
          get "/node/%{id}/relationships/%{direction}" % {:id => get_id(id), :direction => direction || 'all'}
        else
          get "/node/%{id}/relationships/%{direction}/%{types}" % {:id => get_id(id), :direction => direction, :types => Array(types).join('&')}
        end
      end

      # Relationships

      def batch_get_relationship(id)
        get "/relationship/%{id}" % {:id => get_id(id)}
      end

      def batch_delete_relationship(id)
        delete "/relationship/%{id}" % {:id => get_id(id)}
      end

      def batch_create_relationship(type, from, to, data = nil)
        post build_node_uri(from) + "/relationships" do
          {
            :to   => build_node_uri(to),
            :type => type,
            :data => data
          }
        end
      end

      # RelationshipIndexes

      def batch_create_unique_relationship(index, key, value, type, from, to, props = nil)
        post "/index/relationship/%{index}?unique" % {:index => index} do
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

      def batch_add_relationship_to_index(index, key, value, id)
        post "/index/relationship/%{index}" % {:index => index} do
          {
            :uri   => build_relationship_uri(id),
            :key   => key,
            :value => value
          }
        end
      end

      def batch_get_relationship_index(index, key, value)
        get "/index/relationship/%{index}/%{key}/%{value}" % {:index => index, :key => key, :value => encode(value)}
      end

      def batch_remove_relationship_from_index(index, key_or_id, value_or_id = nil, id = nil)
        delete remove_from_index_path("relationship", index, key_or_id, value_or_id, id)
      end

      # RelationshipProperties

      def batch_set_relationship_property(id, property)
        put "/relationship/%{id}/properties/%{property}" % {:id => get_id(id), :property => property.keys.first} do
          property.values.first
        end
      end

      def batch_reset_relationship_properties(id, body)
        put build_relationship_uri(id) + "/properties" do
          body
        end
      end

      # Cypher

      def batch_execute_query(query, params = nil)
        request = post @connection.cypher_path do
          {
            :query => query
          }
        end

        request[:body].merge!({ :params => params }) if params

        request
      end

      # Gremlin

      def batch_execute_script(script, params = nil)
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
          "/index/#{klass}/%{index}/%{key}/%{value}/%{id}" % {:index => index, :key => key_or_id, :value => value_or_id, :id => get_id(id)}
        elsif value_or_id
          "/index/#{klass}/%{index}/%{key}/%{id}" % {:index => index, :key => key_or_id, :id => get_id(value_or_id)}
        else
          "/index/#{klass}/%{index}/%{id}" % {:index => index, :id => get_id(key_or_id)}
        end
      end

      # Spatial
      
      def batch_get_spatial
        get "/ext/SpatialPlugin"
      end
    
      def batch_add_point_layer(layer, lat = nil, lon = nil)
         post "/ext/SpatialPlugin/graphdb/addSimplePointLayer" do
          {
              :layer => layer,
              :lat => lat || "lat",
              :lon => lon || "lon"
            }
          end
      end

      def batch_add_editable_layer(layer, format = "WKT", node_property_name = "wkt")
        post "/ext/SpatialPlugin/graphdb/addEditableLayer" do 
          {
              :layer => layer,
              :format => format,
              :nodePropertyName => node_property_name
            }
        end
      end

      def batch_get_layer(layer)
        post "/ext/SpatialPlugin/graphdb/getLayer" do
          {
              :layer => layer
            }
        end
      end

      def batch_add_geometry_to_layer(layer, geometry)
        post "/ext/SpatialPlugin/graphdb/addGeometryWKTToLayer" do 
          {
              :layer => layer,
              :geometry => geometry
            }
        end
      end
    
      def batch_edit_geometry_from_layer(layer, geometry, node)
        post "/ext/SpatialPlugin/graphdb/updateGeometryFromWKT" do 
          {
              :layer => layer,
              :geometry => geometry,
              :geometryNodeId => get_id(node)
            }
        end
      end
    
      def batch_add_node_to_layer(layer, node)
        post "/ext/SpatialPlugin/graphdb/addNodeToLayer" do 
          {
              :layer => layer,
              :node => get_id(node)
            }
        end
      end
    
      def batch_find_geometries_in_bbox(layer, minx, maxx, miny, maxy)
        post "/ext/SpatialPlugin/graphdb/findGeometriesInBBox" do 
          {
              :layer => layer,
              :minx => minx,
              :maxx => maxx,
              :miny => miny,
              :maxy => maxy
            }
        end
      end
    
      def batch_find_geometries_within_distance(layer, pointx, pointy, distance)
        post "/ext/SpatialPlugin/graphdb/findGeometriesWithinDistance" do 
          {
              :layer => layer,
              :pointX => pointx,
              :pointY => pointy,
              :distanceInKm => distance
            }
        end
      end
      
      def batch_create_spatial_index(name, type, lat, lon)
        post "/index/node" do
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

      def batch_add_node_to_spatial_index(index, id)
        post "/index/node/%{index}" % {:index => index} do
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
