module Neography
  class Rest
    class Spatial
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :index,                          "/ext/SpatialPlugin"
      add_path :add_simple_point_layer,         "/ext/SpatialPlugin/graphdb/addSimplePointLayer"
      add_path :add_editable_layer,             "/ext/SpatialPlugin/graphdb/addEditableLayer"
      add_path :get_layer,                      "/ext/SpatialPlugin/graphdb/getLayer"
      add_path :add_geometry_to_layer,          "/ext/SpatialPlugin/graphdb/addGeometryWKTToLayer"
      add_path :edit_geometry_from_layer,       "/ext/SpatialPlugin/graphdb/updateGeometryFromWKT"
      add_path :add_node_to_layer,              "/ext/SpatialPlugin/graphdb/addNodeToLayer"
      add_path :find_geometries_in_bbox,        "/ext/SpatialPlugin/graphdb/findGeometriesInBBox"
      add_path :find_geometries_within_distance,"/ext/SpatialPlugin/graphdb/findGeometriesWithinDistance"
      add_path :create_index,                   "/index/node"
      add_path :add_to_index,                   "/index/node/:index"

      def initialize(connection)
        @connection ||= connection
      end

      def index
        @connection.get(index_path)
      end

      def add_point_layer(layer, lat, lon)
        options = {
          :body => {
            :layer => layer,
            :lat => lat || "lat",
            :lon => lon || "lon"
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        
        @connection.post(add_simple_point_layer_path, options)        
      end

      def add_editable_layer(layer, format = "WKT", node_property_name = "wkt")
        options = {
          :body => {
            :layer => layer,
            :format => format,
            :nodePropertyName => node_property_name
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        
        @connection.post(add_editable_layer_path, options)        
      end

      def get_layer(layer)
        options = {
          :body => {
            :layer => layer
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post(get_layer_path, options)
      end
      
      def add_geometry_to_layer(layer, geometry)
        options = {
          :body => {
            :layer => layer,
            :geometry => geometry
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post(add_geometry_to_layer_path, options)
      end

      def edit_geometry_from_layer(layer, geometry, node)
        options = {
          :body => {
            :layer => layer,
            :geometry => geometry,
            :geometryNodeId => get_id(node)
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post(edit_geometry_from_layer_path, options)
      end

      def add_node_to_layer(layer, node)
        options = {
          :body => {
            :layer => layer,
            :node => get_id(node)
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post(add_node_to_layer_path, options)
      end

      def find_geometries_in_bbox(layer, minx, maxx, miny, maxy)
        options = {
          :body => {
            :layer => layer,
            :minx => minx,
            :maxx => maxx,
            :miny => miny,
            :maxy => maxy
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post(find_geometries_in_bbox_path, options)
      end

      def find_geometries_within_distance(layer, pointx, pointy, distance)
        options = {
          :body => {
            :layer => layer,
            :pointX => pointx,
            :pointY => pointy,
            :distanceInKm => distance
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post(find_geometries_within_distance_path, options)
      end
      
      def create_spatial_index(name, type, lat, lon)
        options = {
          :body => {
            :name => name,
            :config => {
              :provider => "spatial",
              :geometry_type => type || "point",
              :lat => lat || "lat",
              :lon => lon || "lon"
            }
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post(create_index_path, options) 
      end

      def add_node_to_spatial_index(index, id)
        options = {
          :body => {
            :uri   => @connection.configuration + "/node/#{get_id(id)}",
            :key => "k",
            :value => "v"
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post(add_to_index_path(:index => index), options)
      end

    end
  end
end