require 'forwardable'

require 'neography/rest/helpers'
require 'neography/rest/paths'

require 'neography/rest/schema_indexes'

require 'neography/rest/nodes'
require 'neography/rest/node_properties'
require 'neography/rest/node_relationships'
require 'neography/rest/other_node_relationships'
require 'neography/rest/node_indexes'
require 'neography/rest/node_auto_indexes'
require 'neography/rest/node_traversal'
require 'neography/rest/node_paths'
require 'neography/rest/node_labels'
require 'neography/rest/relationships'
require 'neography/rest/relationship_properties'
require 'neography/rest/relationship_indexes'
require 'neography/rest/relationship_auto_indexes'
require 'neography/rest/relationship_types'
require 'neography/rest/cypher'
require 'neography/rest/gremlin'
require 'neography/rest/extensions'
require 'neography/rest/batch'
require 'neography/rest/clean'
require 'neography/rest/transactions'
require 'neography/rest/spatial'
require 'neography/rest/constraints'

require 'neography/errors'

require 'neography/connection'

module Neography

  class Rest
    include Helpers
    include RelationshipTypes
    include NodeLabels
    include SchemaIndexes
    include Constraints
    include Transactions
    include Nodes
    include NodeProperties
    include Relationships
    include RelationshipProperties
    include NodeRelationships
    include OtherNodeRelationships
    include NodeIndexes
    include NodeAutoIndexes
    include RelationshipIndexes
    include RelationshipAutoIndexes
    include NodeTraversal
    extend Forwardable

    attr_reader :connection

    def_delegators :@connection, :configuration

    def initialize(options = ENV['NEO4J_URL'] || {})
      @connection = Connection.new(options)

      @node_paths                ||= NodePaths.new(@connection)

      @cypher                    ||= Cypher.new(@connection)
      @gremlin                   ||= Gremlin.new(@connection)
      @extensions                ||= Extensions.new(@connection)
      @batch                     ||= Batch.new(@connection)
      @clean                     ||= Clean.new(@connection)
      @spatial                   ||= Spatial.new(@connection)
    end   

    alias_method :list_indexes, :list_node_indexes
    alias_method :add_to_index, :add_node_to_index
    alias_method :remove_from_index, :remove_node_from_index
    alias_method :get_index, :get_node_index
      
    def delete_node!(id)
      relationships = get_node_relationships(get_id(id))
      relationships.each do |relationship|
        delete_relationship(relationship["self"].split('/').last)
      end unless relationships.nil?

      delete_node(id)
    end

    #  This is not yet implemented in the REST API
    #
    # def get_all_node
    #   puts "get all nodes"
    #   get("/nodes/")
    # end

    # relationships

    def get_relationship_start_node(rel)
      get_node(rel["start"])
    end

    def get_relationship_end_node(rel)
      get_node(rel["end"])
    end 

    # paths

    def get_path(from, to, relationships, depth = 1, algorithm = "shortestPath")
      @node_paths.get(from, to, relationships, depth, algorithm)
    end

    def get_paths(from, to, relationships, depth = 1, algorithm = "allPaths")
      @node_paths.get_all(from, to, relationships, depth, algorithm)
    end

    def get_shortest_weighted_path(from, to, relationships, weight_attr = "weight", depth = 1, algorithm = "dijkstra")
      @node_paths.shortest_weighted(from, to, relationships, weight_attr, depth, algorithm)
    end

    # cypher query

    def execute_query(query, params = {}, cypher_options = nil)
      @cypher.query(query, params, cypher_options)
    end

    # gremlin script

    def execute_script(script, params = {})
      @gremlin.execute(script, params)
    end

    # unmanaged extensions

    def post_extension(path, params = {}, headers = nil)
      @extensions.post(path, params, headers)
    end

    def get_extension(path)
      @extensions.get(path)
    end

    # batch

    def batch(*args)
      @batch.execute(*args)
    end

    def batch_not_streaming(*args)
      @batch.not_streaming(*args)
    end
    
    # spatial
    
    def get_spatial
      @spatial.index
    end
    
    def add_point_layer(layer, lat = nil, lon = nil)
      @spatial.add_point_layer(layer, lat, lon)
    end

    def add_editable_layer(layer, format, node_property_name)
      @spatial.add_editable_layer(layer, format, node_property_name)
    end

    def get_layer(layer)
      @spatial.get_layer(layer)
    end

    def add_geometry_to_layer(layer, geometry)
      @spatial.add_geometry_to_layer(layer, geometry)
    end
    
    def edit_geometry_from_layer(layer, geometry, node)
      @spatial.edit_geometry_from_layer(layer, geometry, node)
    end
    
    def add_node_to_layer(layer, node)
      @spatial.add_node_to_layer(layer, node)
    end
    
    def find_geometries_in_bbox(layer, minx, maxx, miny, maxy)
      @spatial.find_geometries_in_bbox(layer, minx, maxx, miny, maxy)
    end
    
    def find_geometries_within_distance(layer, pointx, pointy, distance)
      @spatial.find_geometries_within_distance(layer, pointx, pointy, distance)
    end
    
    def create_spatial_index(name, type = nil, lat = nil, lon = nil)
      @spatial.create_spatial_index(name, type, lat, lon)
    end
    
    def add_node_to_spatial_index(index, id)
      @spatial.add_node_to_spatial_index(index, id)
    end
    
    # clean database

    # For testing (use a separate neo4j instance)
    # call this before each test or spec
    def clean_database(sanity_check = "not_really")
      if sanity_check == "yes_i_really_want_to_clean_the_database"
        @clean.execute
        true
      else
        false
      end
    end

  end
end
