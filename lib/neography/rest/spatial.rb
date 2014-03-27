module Neography
  class Rest
    module Spatial
      include Neography::Rest::Helpers
    
      def get_spatial
        @connection.get("/ext/SpatialPlugin")
      end

      def add_point_layer(layer, lat = nil, lon = nil)
        options = {
          :body => {
            :layer => layer,
            :lat => lat || "lat",
            :lon => lon || "lon"
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        
        @connection.post("/ext/SpatialPlugin/graphdb/addSimplePointLayer", options)        
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
        
        @connection.post("/ext/SpatialPlugin/graphdb/addEditableLayer", options)        
      end

      def get_layer(layer)
        options = {
          :body => {
            :layer => layer
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post("/ext/SpatialPlugin/graphdb/getLayer", options)
      end
      
      def add_geometry_to_layer(layer, geometry)
        options = {
          :body => {
            :layer => layer,
            :geometry => geometry
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post("/ext/SpatialPlugin/graphdb/addGeometryWKTToLayer", options)
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
        @connection.post("/ext/SpatialPlugin/graphdb/updateGeometryFromWKT", options)
      end

      def add_node_to_layer(layer, node)
        options = {
          :body => {
            :layer => layer,
            :node => get_id(node)
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;charset=UTF-8'})
        }
        @connection.post("/ext/SpatialPlugin/graphdb/addNodeToLayer", options)
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
        @connection.post("/ext/SpatialPlugin/graphdb/findGeometriesInBBox", options)
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
        @connection.post("/ext/SpatialPlugin/graphdb/findGeometriesWithinDistance", options)
      end
      
      def create_spatial_index(name, type = nil, lat = nil, lon = nil)
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
        @connection.post("/index/node", options) 
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
        @connection.post("/index/node/%{index}" % {:index => index}, options)
      end

    end
  end
end