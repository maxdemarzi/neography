require 'forwardable'

module Neography

  class Rest
    include HTTParty
    include Helpers
    extend Delegation
    extend Forwardable

    attr_reader :connection

    def_delegators :@connection, :configuration

    def initialize(options = ENV['NEO4J_URL'] || {})
      @connection = Connection.new(options)
    end

    def_rest_delegations :nodes => {
      :get_root              => :root,
      :create_node           => :create,
      :create_nodes          => :create_multiple,
      :create_nodes_threaded => :create_multiple_threaded,
      :get_node              => :get,
      :get_nodes             => :get_each,
      :delete_node           => :delete,
    }

    def_rest_delegations :node_properties => {
      :reset_node_properties  => :reset,
      :get_node_properties    => :get,
      :remove_node_properties => :remove,
      :set_node_properties    => :set
    }

    def_rest_delegations :relationships => {
      :get_relationship    => :get,
      :delete_relationship => :delete
    }

    def_rest_delegations :relationship_properties => {
      :reset_relationship_properties  => :reset,
      :get_relationship_properties    => :get,
      :remove_relationship_properties => :remove,
      :set_relationship_properties    => :set
    }

    def_rest_delegations :node_relationships => {
      :create_relationship    => :create,
      :get_node_relationships => :get
    }

    def_rest_delegations :node_indexes => {
      :list_node_indexes      => :list,
      :create_node_index      => :create,
      :create_node_auto_index => :create_auto,
      :create_unique_node     => :create_unique,
      :add_node_to_index      => :add,
      :remove_node_from_index => :remove,
      :get_node_index         => :get,
      :find_node_index        => :find
    }

    alias_method :list_indexes, :list_node_indexes
    alias_method :add_to_index, :add_node_to_index
    alias_method :remove_from_index, :remove_node_from_index
    alias_method :get_index, :get_node_index

    def_rest_delegations :node_auto_indexes => {
      :get_node_auto_index             => :get,
      :find_node_auto_index            => :find_or_query,
      :get_node_auto_index_status      => :status,
      :set_node_auto_index_status      => :status=,
      :get_node_auto_index_properties  => :properties,
      :add_node_auto_index_property    => :add_property,
      :remove_node_auto_index_property => :remove_property
    }

    def_rest_delegations :relationship_indexes => {
      :list_relationship_indexes      => :list,
      :create_relationship_index      => :create,
      :create_relationship_auto_index => :create_auto,
      :create_unique_relationship     => :create_unique,
      :add_relationship_to_index      => :add,
      :remove_relationship_from_index => :remove,
      :get_relationship_index         => :get,
      :find_relationship_index        => :find
    }

    def_rest_delegations :relationship_auto_indexes => {
      :get_relationship_auto_index             => :get,
      :find_relationship_auto_index            => :find_or_query,
      :get_relationship_auto_index_status      => :status,
      :set_relationship_auto_index_status      => :status=,
      :get_relationship_auto_index_properties  => :properties,
      :add_relationship_auto_index_property    => :add_property,
      :remove_relationship_auto_index_property => :remove_property
    }

    def_rest_delegations :node_paths => {
      :get_path                   => :get,
      :get_paths                  => :get_all,
      :get_shortest_weighted_path => :shortest_weighted
    }

    def_rest_delegations :batch_rest => {
      :batch               => :execute,
      :batch_not_streaming => :not_streaming
    }

    # traversal
    def_delegator :node_traversal, :traverse, :traverse

    # cypher query
    def_delegator :cypher, :query, :execute_query

    # gremlin script
    def_delegator :gremlin, :execute, :execute_script

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
