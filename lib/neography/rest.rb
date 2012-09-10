require 'forwardable'

module Neography

  class Rest
    include HTTParty
    include Helpers
    extend Forwardable

    attr_reader :connection

    def_delegators :@connection, :configuration

    def initialize(options = ENV['NEO4J_URL'] || {})
      @connection = Connection.new(options)
    end

    # nodes
    def_delegator :nodes, :root,                     :get_root
    def_delegator :nodes, :create,                   :create_node
    def_delegator :nodes, :create_multiple,          :create_nodes
    def_delegator :nodes, :create_multiple_threaded, :create_nodes_threaded
    def_delegator :nodes, :get,                      :get_node
    def_delegator :nodes, :get_each,                 :get_nodes
    def_delegator :nodes, :delete,                   :delete_node

    # node properties
    def_delegator :node_properties, :reset,  :reset_node_properties
    def_delegator :node_properties, :get,    :get_node_properties
    def_delegator :node_properties, :remove, :remove_node_properties
    def_delegator :node_properties, :set,    :set_node_properties

    # relationships
    def_delegator :relationships, :get,    :get_relationship
    def_delegator :relationships, :delete, :delete_relationship

    # relationship properties
    def_delegator :relationship_properties, :reset,  :reset_relationship_properties
    def_delegator :relationship_properties, :get,    :get_relationship_properties
    def_delegator :relationship_properties, :remove, :remove_relationship_properties
    def_delegator :relationship_properties, :set,    :set_relationship_properties

    # node relationships
    def_delegator :node_relationships, :create, :create_relationship
    def_delegator :node_relationships, :get, :get_node_relationships

    # node indexes
    def_delegator :node_indexes, :list,          :list_node_indexes
    def_delegator :node_indexes, :create,        :create_node_index
    def_delegator :node_indexes, :create_auto,   :create_node_auto_index
    def_delegator :node_indexes, :create_unique, :create_unique_node
    def_delegator :node_indexes, :add,           :add_node_to_index
    def_delegator :node_indexes, :remove,        :remove_node_from_index
    def_delegator :node_indexes, :get,           :get_node_index
    def_delegator :node_indexes, :find,          :find_node_index

    alias_method :list_indexes, :list_node_indexes
    alias_method :add_to_index, :add_node_to_index
    alias_method :remove_from_index, :remove_node_from_index
    alias_method :get_index, :get_node_index

    # auto node indexes
    def_delegator :node_auto_indexes, :get,             :get_node_auto_index
    def_delegator :node_auto_indexes, :find_or_query,   :find_node_auto_index
    def_delegator :node_auto_indexes, :status,          :get_node_auto_index_status
    def_delegator :node_auto_indexes, :status=,         :set_node_auto_index_status
    def_delegator :node_auto_indexes, :properties,      :get_node_auto_index_properties
    def_delegator :node_auto_indexes, :add_property,    :add_node_auto_index_property
    def_delegator :node_auto_indexes, :remove_property, :remove_node_auto_index_property

    # relationship indexes
    def_delegator :relationship_indexes, :list,          :list_relationship_indexes
    def_delegator :relationship_indexes, :create,        :create_relationship_index
    def_delegator :relationship_indexes, :create_auto,   :create_relationship_auto_index
    def_delegator :relationship_indexes, :create_unique, :create_unique_relationship
    def_delegator :relationship_indexes, :add,           :add_relationship_to_index
    def_delegator :relationship_indexes, :remove,        :remove_relationship_from_index
    def_delegator :relationship_indexes, :get,           :get_relationship_index
    def_delegator :relationship_indexes, :find,          :find_relationship_index

    # relationship auto indexes
    def_delegator :relationship_auto_indexes, :get,             :get_relationship_auto_index
    def_delegator :relationship_auto_indexes, :find_or_query,   :find_relationship_auto_index
    def_delegator :relationship_auto_indexes, :status,          :get_relationship_auto_index_status
    def_delegator :relationship_auto_indexes, :status=,         :set_relationship_auto_index_status
    def_delegator :relationship_auto_indexes, :properties,      :get_relationship_auto_index_properties
    def_delegator :relationship_auto_indexes, :add_property,    :add_relationship_auto_index_property
    def_delegator :relationship_auto_indexes, :remove_property, :remove_relationship_auto_index_property

    # traversal
    def_delegator :node_traversal, :traverse, :traverse

    # paths
    def_delegator :node_paths, :get,               :get_path
    def_delegator :node_paths, :get_all,           :get_paths
    def_delegator :node_paths, :shortest_weighted, :get_shortest_weighted_path

    # cypher query
    def_delegator :cypher, :query, :execute_query

    # gremlin script
    def_delegator :gremlin, :execute, :execute_script

    # batch
    def_delegator :batch_rest, :execute,        :batch
    def_delegator :batch_rest, :not_streaming,  :batch_not_streaming

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

    def delete_node!(id)
      relationships = get_node_relationships(get_id(id))
      relationships.each do |relationship|
        delete_relationship(relationship["self"].split('/').last)
      end unless relationships.nil?

      delete_node(id)
    end

    def get_relationship_start_node(rel)
      get_node(rel["start"])
    end

    def get_relationship_end_node(rel)
      get_node(rel["end"])
    end

    #  This is not yet implemented in the REST API
    #
    # def get_all_node
    #   puts "get all nodes"
    #   get("/nodes/")
    # end

    private

    def nodes
      @nodes ||= Nodes.new(@connection)
    end

    def node_properties
      @node_properties ||= NodeProperties.new(@connection)
    end

    def node_relationships
      @node_relationships ||= NodeRelationships.new(@connection)
    end

    def node_indexes
      @node_indexes ||= NodeIndexes.new(@connection)
    end

    def node_auto_indexes
      @node_auto_indexes ||= NodeAutoIndexes.new(@connection)
    end

    def node_traversal
      @node_traversal ||= NodeTraversal.new(@connection)
    end

    def node_paths
      @node_paths ||= NodePaths.new(@connection)
    end

    def relationships
      @relationships ||= Relationships.new(@connection)
    end

    def relationship_properties
      @relationship_properties ||= RelationshipProperties.new(@connection)
    end

    def relationship_indexes
      @relationship_indexes ||= RelationshipIndexes.new(@connection)
    end

    def relationship_auto_indexes
      @relationship_auto_indexes ||= RelationshipAutoIndexes.new(@connection)
    end

    def cypher
      @cypher ||= Cypher.new(@connection)
    end

    def gremlin
      @gremlin ||= Gremlin.new(@connection)
    end

    def batch_rest
      @batch ||= Batch.new(@connection)
    end

    def clean
      @clean ||= Clean.new(@connection)
    end

  end
end
