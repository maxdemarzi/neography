require 'forwardable'

require 'neography/rest/helpers'
require 'neography/rest/paths'

require 'neography/rest/properties'
require 'neography/rest/indexes'
require 'neography/rest/auto_indexes'
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
    extend Forwardable

    attr_reader :connection

    def_delegators :@connection, :configuration

    def initialize(options = ENV['NEO4J_URL'] || {})
      @connection = Connection.new(options)

      @nodes                     = Nodes.new(@connection)
      @node_properties           = NodeProperties.new(@connection)
      @node_relationships        = NodeRelationships.new(@connection)
      @other_node_relationships  = OtherNodeRelationships.new(@connection)
      @node_indexes              = NodeIndexes.new(@connection)
      @node_auto_indexes         = NodeAutoIndexes.new(@connection)
      @schema_indexes            = SchemaIndexes.new(@connection)
      @node_traversal            = NodeTraversal.new(@connection)
      @node_paths                = NodePaths.new(@connection)
      @node_labels               = NodeLabels.new(@connection)

      @relationships             = Relationships.new(@connection)
      @relationship_properties   = RelationshipProperties.new(@connection)
      @relationship_indexes      = RelationshipIndexes.new(@connection)
      @relationship_auto_indexes = RelationshipAutoIndexes.new(@connection)
      @relationship_types        = RelationshipTypes.new(@connection)

      @cypher                    = Cypher.new(@connection)
      @gremlin                   = Gremlin.new(@connection)
      @extensions                = Extensions.new(@connection)
      @batch                     = Batch.new(@connection)
      @clean                     = Clean.new(@connection)
      @transactions              = Transactions.new(@connection)
      @spatial                   = Spatial.new(@connection)
      @constraints               = Constraints.new(@connection)
    end

    # meta-data

    def list_relationship_types
      @relationship_types.list
    end
    
    # labels
    
    def list_labels
      @node_labels.list
    end
    
    def add_label(id, label)
      @node_labels.add(id, label)
    end

    def set_label(id, label)
      @node_labels.set(id, label)
    end

    def delete_label(id, label)
      @node_labels.delete(id, label)
    end
    
    def get_node_labels(id)
      @node_labels.get(id)
    end
    
    def get_nodes_labeled(label)
      @node_labels.get_nodes(label)
    end

    def find_nodes_labeled(label, hash)
      @node_labels.find_nodes(label, hash)
    end

    # schema indexes
 
    def get_schema_index(label)
      @schema_indexes.list(label)
    end
    
    def create_schema_index(label, properties)
      @schema_indexes.create(label, properties)
    end
    
    def delete_schema_index(label, property)
      @schema_indexes.drop(label, property)
    end

    # constraints
    
    def get_constraints(label=nil)
      label.nil? ? @constraints.list : @constraints.get(label)
    end

    def drop_constraint(label, property)
      @constraints.drop(label, property)
    end

    def get_uniqueness(label)
      @constraints.get_uniqueness(label)
    end

    def get_unique_constraint(label, property)
      @constraints.get_unique(label, property)
    end

    def create_unique_constraint(label, property)
      @constraints.create_unique(label, property)
    end
      
    # transactions
    
    def begin_transaction(statements=nil)
      @transactions.begin(statements)
    end
    
    def in_transaction(tx, statements)
      @transactions.add(tx, statements)    
    end
    
    def keep_transaction(tx)
      @transactions.add(tx)    
    end

    def commit_transaction(tx, statements=[])
      if (tx.is_a?(Hash) || tx.is_a?(Integer))
        @transactions.commit(tx, statements)    
      else
        @transactions.begin(tx, "/commit")
      end
    end
    
    def rollback_transaction(tx)
      @transactions.rollback(tx)    
    end    
    
    # nodes

    def get_root
      @nodes.root
    end

    def get_node(id)
      @nodes.get(id)
    end

    def get_nodes(*args)
      @nodes.get_each(*args)
    end

    def create_node(*args)
      @nodes.create(*args)
    end

    def create_nodes(args)
      @nodes.create_multiple(args)
    end

    def create_nodes_threaded(args)
      @nodes.create_multiple_threaded(args)
    end

    def delete_node(id)
      @nodes.delete(id)
    end

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

    # node properties

    def get_node_properties(id, *properties)
      @node_properties.get(id, *properties.flatten)
    end

    def set_node_properties(id, properties)
      @node_properties.set(id, properties)
    end

    def reset_node_properties(id, properties)
      @node_properties.reset(id, properties)
    end

    def remove_node_properties(id, *properties)
      @node_properties.remove(id, *properties.flatten)
    end

    # relationships

    def get_relationship(id)
      @relationships.get(id)
    end

    def delete_relationship(id)
      @relationships.delete(id)
    end

    def get_relationship_start_node(rel)
      get_node(rel["start"])
    end

    def get_relationship_end_node(rel)
      get_node(rel["end"])
    end
    
    # relationship properties

    def get_relationship_properties(id, *properties)
      @relationship_properties.get(id, *properties.flatten)
    end

    def set_relationship_properties(id, properties)
      @relationship_properties.set(id, properties)
    end

    def reset_relationship_properties(id, properties)
      @relationship_properties.reset(id, properties)
    end

    def remove_relationship_properties(id, *properties)
      @relationship_properties.remove(id, *properties.flatten)
    end

    # node relationships

    def get_node_relationships(id, dir = nil, types = nil)
      @node_relationships.get(id, dir, types)
    end

    def get_node_relationships_to(id, other_id, dir = "all", types = nil)
      @other_node_relationships.get(id, other_id, dir, Array(types || [nil]))
    end

    def create_relationship(type, from, to, props = nil)
      @node_relationships.create(type, from, to, props)
    end

    # node indexes

    def list_node_indexes
      @node_indexes.list
    end
    alias_method :list_indexes, :list_node_indexes

    def create_node_index(name, type = "exact", provider = "lucene", extra_config = nil)
      @node_indexes.create(name, type, provider, extra_config)
    end

    def create_node_auto_index(type = "exact", provider = "lucene")
      @node_indexes.create_auto(type, provider)
    end

    def create_unique_node(index, key, value, props={})
      @node_indexes.create_unique(index, key, value, props)
    end

    def add_node_to_index(index, key, value, id, unique=false)
      @node_indexes.add(index, key, value, id, unique)
    end
    alias_method :add_to_index, :add_node_to_index

    def remove_node_from_index(index, id_or_key, id_or_value = nil, id = nil)
      @node_indexes.remove(index, id_or_key, id_or_value, id)
    end
    alias_method :remove_from_index, :remove_node_from_index

    def get_node_index(index, key, value)
      @node_indexes.get(index, key, value)
    end
    alias_method :get_index, :get_node_index

    def find_node_index(index, key_or_query, value = nil)
      @node_indexes.find(index, key_or_query, value)
    end

    def drop_node_index(index)
      @node_indexes.drop(index)
    end

    # auto node indexes

    def get_node_auto_index(key, value)
      @node_auto_indexes.get(key, value)
    end

    def find_node_auto_index(key_or_query, value = nil)
      @node_auto_indexes.find_or_query(key_or_query, value)
    end

    def get_node_auto_index_status
      @node_auto_indexes.status
    end

    def set_node_auto_index_status(change_to = true)
      @node_auto_indexes.status = change_to
    end

    def get_node_auto_index_properties
      @node_auto_indexes.properties
    end

    def add_node_auto_index_property(property)
      @node_auto_indexes.add_property(property)
    end

    def remove_node_auto_index_property(property)
      @node_auto_indexes.remove_property(property)
    end

    # relationship indexes

    def list_relationship_indexes
      @relationship_indexes.list
    end

    def create_relationship_index(name, type = "exact", provider = "lucene")
      @relationship_indexes.create(name, type, provider)
    end

    def create_relationship_auto_index(type = "exact", provider = "lucene")
      @relationship_indexes.create_auto(type, provider)
    end

    def create_unique_relationship(index, key, value, type, from, to, props = nil)
      @relationship_indexes.create_unique(index, key, value, type, from, to, props)
    end

    def add_relationship_to_index(index, key, value, id)
      @relationship_indexes.add(index, key, value, id)
    end

    def remove_relationship_from_index(index, id_or_key, id_or_value = nil, id = nil)
      @relationship_indexes.remove(index, id_or_key, id_or_value, id)
    end

    def get_relationship_index(index, key, value)
      @relationship_indexes.get(index, key, value)
    end

    def find_relationship_index(index, key_or_query, value = nil)
      @relationship_indexes.find(index, key_or_query, value)
    end
    
    def drop_relationship_index(index)
      @relationship_indexes.drop(index)
    end    

    # relationship auto indexes

    def get_relationship_auto_index(key, value)
      @relationship_auto_indexes.get(key, value)
    end

    def find_relationship_auto_index(key_or_query, value = nil)
      @relationship_auto_indexes.find_or_query(key_or_query, value)
    end

    def get_relationship_auto_index_status
      @relationship_auto_indexes.status
    end

    def set_relationship_auto_index_status(change_to = true)
      @relationship_auto_indexes.status = change_to
    end

    def get_relationship_auto_index_properties
      @relationship_auto_indexes.properties
    end

    def add_relationship_auto_index_property(property)
      @relationship_auto_indexes.add_property(property)
    end

    def remove_relationship_auto_index_property(property)
      @relationship_auto_indexes.remove_property(property)
    end

    # traversal

    def traverse(id, return_type, description)
      @node_traversal.traverse(id, return_type, description)
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
