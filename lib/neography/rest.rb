require 'forwardable'

require 'neography/rest/helpers'
require 'neography/rest/auth'
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
    include Auth
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
    include NodePaths
    include Cypher
    include Gremlin
    include Batch
    include Extensions
    include Spatial
    include Clean
    extend Forwardable

    attr_reader :connection

    def_delegators :@connection, :configuration

    def initialize(options = {})
      @connection = Connection.new(options)
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
    
  end
end
