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

      def initialize(connection)
        @connection = connection
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
            :layer => name,
            :format => format,
            :nodePropertyName => node_property_name
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        
        @connection.post(add_editable_layer_path, options)        
      end


    end
  end
end