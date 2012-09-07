require 'forwardable'

module Neography

  class Rest
    include HTTParty
    include Helpers
    extend Forwardable

    attr_reader :connection

    def_delegators :@connection, :configuration,
      :get, :post, :put, :delete

    def initialize(options=ENV['NEO4J_URL'] || {})
      @connection = Connection.new(options)

      @nodes                    = Nodes.new(@connection)
      @node_properties          = NodeProperties.new(@connection)
      @node_relationships       = NodeRelationships.new(@connection)
      @node_indexes             = NodeIndexes.new(@connection)
      @node_auto_indexes        = NodeAutoIndexes.new(@connection)
      @relationships            = Relationships.new(@connection)
      @relationship_properties  = RelationshipProperties.new(@connection)
    end

    def get_root
      @nodes.root
    end

    def create_node(*args)
      @nodes.create(*args)
    end

    def create_nodes(nodes)
      @nodes.create_multiple(nodes)
    end

    def create_nodes_threaded(nodes)
      @nodes.create_multiple_threaded(nodes)
    end

    #  This is not yet implemented in the REST API
    #
    # def get_all_node
    #   puts "get all nodes"
    #   get("/nodes/")
    # end

    # nodes

    def get_node(id)
      @nodes.get(id)
    end

    def get_nodes(*nodes)
      @nodes.get_each(*nodes)
    end

    def delete_node(id)
      @nodes.delete(id)
    end

    def delete_node!(id)
      relationships = get_node_relationships(get_id(id))
      relationships.each { |r| delete_relationship(r["self"].split('/').last) } unless relationships.nil?
      delete_node(id)
    end

    # node properties

    def reset_node_properties(id, properties)
      @node_properties.reset(id, properties)
    end

    def get_node_properties(id, *properties)
      @node_properties.get(id, *properties.flatten)
    end

    def remove_node_properties(id, *properties)
      @node_properties.remove(id, *properties.flatten)
    end

    def set_node_properties(id, properties)
      @node_properties.set(id, properties)
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

    def reset_relationship_properties(id, properties)
      @relationship_properties.reset(id, properties)
    end

    def get_relationship_properties(id, properties = nil)
      @relationship_properties.get(id, properties)
    end

    def remove_relationship_properties(id, properties = nil)
      @relationship_properties.remove(id, properties)
    end

    def set_relationship_properties(id, properties)
      @relationship_properties.set(id, properties)
    end

    # node relationships

    def create_relationship(type, from, to, props = nil)
      @node_relationships.create(type, from, to, props)
    end

    def get_node_relationships(id, dir = nil, types = nil)
      @node_relationships.get(id, dir, types)
    end

    # node indexes

    def list_node_indexes
      @node_indexes.list
    end
    alias_method :list_indexes, :list_node_indexes

    def create_node_index(name, type = "exact", provider = "lucene")
      @node_indexes.create(name, type, provider)
    end

    def create_node_auto_index(type = "exact", provider = "lucene")
      @node_indexes.create_auto(type, provider)
    end

    def add_node_to_index(index, key, value, id)
      @node_indexes.add_node(index, key, value, id)
    end
    alias_method :add_to_index, :add_node_to_index

    def create_unique_node(index, key, value, props={})
      @node_indexes.create_unique_node(index, key, value, props)
    end

    def remove_node_from_index(*args)
      case args.size
      when 4 then @node_indexes.remove_node_by_value(args[0], args[3], args[1], args[2])
      when 3 then @node_indexes.remove_node_by_key(args[0], args[2], args[1])
      when 2 then @node_indexes.remove_node(args[0], args[1])
      end
    end
    alias_method :remove_from_index, :remove_node_from_index


    def get_node_index(index, key, value)
      @node_indexes.get_node(index, key, value)
    end
    alias_method :get_index, :get_node_index

    def find_node_index(*args)
      case args.size
      when 3 then index = @node_indexes.find_node_by_value(args[0], args[1], args[2])
      when 2 then index = @node_indexes.find_node_by_query(args[0], args[1])
      end
      return nil if index.empty?
      index
    end

    # auto node indexes

    def get_node_auto_index(key, value)
      @node_auto_indexes.get(key, value)
    end

    def find_node_auto_index(*args)
      case args.size
      when 2 then index = @node_auto_indexes.find(args[0], args[1])
      when 1 then index = @node_auto_indexes.query(args[0])
      end
      return nil if index.empty?
      index
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

      def create_unique_relationship(index, key, value, type, from, to)
        body = {:key=>key,:value=>value, :type => type }
        body[:start] = self.configuration + "/node/#{get_id(from)}"
        body[:end] = self.configuration + "/node/#{get_id(to)}"
        options = { :body => body.to_json, :headers => {'Content-Type' => 'application/json'} }
        post("/index/relationship/#{index}?unique", options)
      end

      def list_relationship_indexes
        get("/index/relationship")
      end

      def create_relationship_index(name, type = "exact", provider = "lucene")
        options = { :body => ({:name => name, :config => {:type => type, :provider => provider}}).to_json, :headers => {'Content-Type' => 'application/json'} } 
        post("/index/relationship", options)
      end

      def create_relationship_auto_index(type = "exact", provider = "lucene")
        create_relationship_index("relationship_auto_index", type, provider)
      end

      def add_relationship_to_index(index, key, value, id)
        options = { :body => ({:uri => self.configuration + "/relationship/#{get_id(id)}", :key => key, :value => value}).to_json, :headers => {'Content-Type' => 'application/json'} } 
        post("/index/relationship/#{index}", options)
      end

      def remove_relationship_from_index(*args)
        case args.size
          when 4 then delete("/index/relationship/#{args[0]}/#{args[1]}/#{args[2]}/#{get_id(args[3])}")
          when 3 then delete("/index/relationship/#{args[0]}/#{args[1]}/#{get_id(args[2])}")
          when 2 then delete("/index/relationship/#{args[0]}/#{get_id(args[1])}")
        end
      end

      def get_relationship_index(index, key, value)
        index = get("/index/relationship/#{index}/#{key}/#{value}") || Array.new
        return nil if index.empty?
        index
      end

      def find_relationship_index(*args)
        case args.size
          when 3 then index = get("/index/relationship/#{args[0]}/#{args[1]}?query=#{args[2]}") || Array.new
          when 2 then index = get("/index/relationship/#{args[0]}?query=#{args[1]}") || Array.new
        end
        return nil if index.empty?
        index
      end

      # relationship auto indexes

      def get_relationship_auto_index(key, value)
        index = get("/index/auto/relationship/#{key}/#{value}") || Array.new
        return nil if index.empty?
        index
      end

      def find_relationship_auto_index(*args)
        case args.size
          when 2 then index = get("/index/auto/relationship/#{args[0]}/#{args[1]}") || Array.new
          when 1 then index = get("/index/auto/relationship/?query=#{args[0]}") || Array.new
        end
        return nil if index.empty?
        index
      end

      def get_relationship_auto_index_status
        get("/index/auto/relationship/status")
      end

      def set_relationship_auto_index_status(change_to = true)
        options = { :body => change_to.to_json, :headers => {'Content-Type' => 'application/json'} }
        put("/index/auto/relationship/status", options)
      end

      def get_relationship_auto_index_properties
        get("/index/auto/relationship/properties")
      end

      def add_relationship_auto_index_property(property)
        options = { :body => property, :headers => {'Content-Type' => 'application/json'} }
        post("/index/auto/relationship/properties", options)
      end

      def remove_relationship_auto_index_property(property)
        delete("/index/auto/relationship/properties/#{property}")
      end

      # traversal

      def traverse(id, return_type, description)
        options = { :body => {"order" => get_order(description["order"]), 
                              "uniqueness" => get_uniqueness(description["uniqueness"]), 
                              "relationships" => description["relationships"], 
                              "prune_evaluator" => description["prune evaluator"], 
                              "return_filter" => description["return filter"], 
                              "max_depth" => get_depth(description["depth"]), }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        traversal = post("/node/#{get_id(id)}/traverse/#{get_type(return_type)}", options) || Array.new
      end

      # paths

      def get_path(from, to, relationships, depth=1, algorithm="shortestPath")
        options = { :body => {"to" => self.configuration + "/node/#{get_id(to)}", "relationships" => relationships, "max_depth" => depth, "algorithm" => get_algorithm(algorithm) }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        path = post("/node/#{get_id(from)}/path", options) || Hash.new
      end

      def get_paths(from, to, relationships, depth=1, algorithm="allPaths")
        options = { :body => {"to" => self.configuration + "/node/#{get_id(to)}", "relationships" => relationships, "max_depth" => depth, "algorithm" => get_algorithm(algorithm) }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        paths = post("/node/#{get_id(from)}/paths", options) || Array.new
      end
      
      def get_shortest_weighted_path(from, to, relationships, weight_attr='weight', depth=1, algorithm="dijkstra")
        options = { :body => {"to" => self.configuration + "/node/#{get_id(to)}", "relationships" => relationships, "cost_property" => weight_attr, "max_depth" => depth, "algorithm" => get_algorithm(algorithm) }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        paths = post("/node/#{get_id(from)}/paths", options) || Hash.new
      end

      # query

      def execute_query(query, params = {})
          options = { :body => {:query => query, :params => params}.to_json, :headers => {'Content-Type' => 'application/json', 'Accept' => 'application/json;stream=true'} }
          result = post(@connection.cypher_path, options)
      end

      # script
      
      def execute_script(script, params = {})
        options = { :body => {:script => script, :params => params}.to_json , :headers => {'Content-Type' => 'application/json'} }
        result = post(@connection.gremlin_path, options)
        result == "null" ? nil : result
      end

      # batch

      def batch(*args)
        batch = []
        Array(args).each_with_index do |c,i|
          batch << {:id => i}.merge(get_batch(c))
        end
         options = { :body => batch.to_json, :headers => {'Content-Type' => 'application/json', 'Accept' => 'application/json;stream=true'} } 
         post("/batch", options)
      end
      
      def batch_not_streaming(*args)
        batch = []
        Array(args).each_with_index do |c,i|
          batch << {:id => i}.merge(get_batch(c))
        end
         options = { :body => batch.to_json, :headers => {'Content-Type' => 'application/json'} } 
         post("/batch", options)
      end
            
      def get_batch(args)
        case args[0]
          when :get_node
            {:method => "GET", :to => "/node/#{get_id(args[1])}"}
          when :create_node
            {:method => "POST", :to => "/node/", :body => args[1]}
          when :create_unique_node
            {:method => "POST", :to => "/index/node/#{args[1]}?unique", :body => {:key => args[2], :value => args[3], :properties => args[4]}}
          when :set_node_property
            {:method => "PUT", :to => "/node/#{get_id(args[1])}/properties/#{args[2].keys.first}", :body => args[2].values.first}
          when :reset_node_properties
            {:method => "PUT", :to => "/node/#{get_id(args[1])}/properties", :body => args[2]}
          when :get_relationship
            {:method => "GET", :to => "/relationship/#{get_id(args[1])}"}
          when :create_relationship
            {:method => "POST", :to => (args[2].is_a?(String) && args[2].start_with?("{") ? "" : "/node/") + "#{get_id(args[2])}/relationships", :body => {:to => (args[3].is_a?(String) && args[3].start_with?("{") ? "" : "/node/") + "#{get_id(args[3])}", :type => args[1], :data => args[4] } }
          when :create_unique_relationship
            {:method => "POST", :to => "/index/relationship/#{args[1]}?unique", :body => {:key => args[2], :value => args[3], :type => args[4], :start => (args[5].is_a?(String) && args[5].start_with?("{") ? "" : "/node/") + "#{get_id(args[5])}", :end=> (args[6].is_a?(String) && args[6].start_with?("{") ? "" : "/node/") + "#{get_id(args[6])}"} }
          when :delete_relationship
            {:method => "DELETE", :to => "/relationship/#{get_id(args[1])}"}
          when :set_relationship_property
            {:method => "PUT", :to => "/relationship/#{get_id(args[1])}/properties/#{args[2].keys.first}", :body => args[2].values.first}
          when :reset_relationship_properties
            {:method => "PUT", :to => (args[1].is_a?(String) && args[1].start_with?("{") ? "" : "/relationship/") + "#{get_id(args[1])}/properties", :body => args[2]}
          when :add_node_to_index
            {:method => "POST", :to => "/index/node/#{args[1]}", :body => {:uri => (args[4].is_a?(String) && args[4].start_with?("{") ? "" : "/node/") + "#{get_id(args[4])}", :key => args[2], :value => args[3] } }
          when :add_relationship_to_index
            {:method => "POST", :to => "/index/relationship/#{args[1]}", :body => {:uri => (args[4].is_a?(String) && args[4].start_with?("{") ? "" : "/relationship/") + "#{get_id(args[4])}", :key => args[2], :value => args[3] } }
          when :get_node_index
            {:method => "GET", :to => "/index/node/#{args[1]}/#{args[2]}/#{args[3]}"}
          when :get_relationship_index
            {:method => "GET", :to => "/index/relationship/#{args[1]}/#{args[2]}/#{args[3]}"}
          when :get_node_relationships
            {:method => "GET", :to => "/node/#{get_id(args[1])}/relationships/#{args[2] || 'all'}"}
          when :execute_script
            {:method => "POST", :to => @connection.gremlin_path, :body => {:script => args[1], :params => args[2]}}
          when :execute_query
            if args[2]
              {:method => "POST", :to => @connection.cypher_path, :body => {:query => args[1], :params => args[2]}}
            else
              {:method => "POST", :to => @connection.cypher_path, :body => {:query => args[1]}}
            end
          when :remove_node_from_index
            case args.size
              when 5 then {:method => "DELETE", :to => "/index/node/#{args[1]}/#{args[2]}/#{args[3]}/#{get_id(args[4])}" }
              when 4 then {:method => "DELETE", :to => "/index/node/#{args[1]}/#{args[2]}/#{get_id(args[3])}" } 
              when 3 then {:method => "DELETE", :to => "/index/node/#{args[1]}/#{get_id(args[2])}" } 
            end
          when :remove_relationship_from_index
           case args.size
             when 5 then {:method => "DELETE", :to => "/index/relationship/#{args[1]}/#{args[2]}/#{args[3]}/#{get_id(args[4])}" }
             when 4 then {:method => "DELETE", :to => "/index/relationship/#{args[1]}/#{args[2]}/#{get_id(args[3])}" }
             when 3 then {:method => "DELETE", :to => "/index/relationship/#{args[1]}/#{get_id(args[2])}" }
           end
    		  when :delete_node
    		   	{:method => "DELETE", :to => "/node/#{get_id(args[1])}"}
    		  else
            raise "Unknown option #{args[0]}"
        end
      end

      # delete

      # For testing (use a separate neo4j instance)
      # call this before each test or spec
      def clean_database(sanity_check = "not_really")
        if sanity_check == "yes_i_really_want_to_clean_the_database"
          delete("/cleandb/secret-key")
          true
        else
          false
        end
      end


      def get_algorithm(algorithm)
        case algorithm
          when :shortest, "shortest", :shortestPath, "shortestPath", :short, "short"
            "shortestPath"
          when :allSimplePaths, "allSimplePaths", :simple, "simple"
            "allSimplePaths"
          when :dijkstra, "dijkstra"
            "dijkstra"
          else
            "allPaths"
        end
      end

      def get_order(order)
        case order
          when :breadth, "breadth", "breadth first", "breadthFirst", :wide, "wide"
            "breadth first"
          else
            "depth first"
        end
      end

      def get_type(type)
        case type
          when :relationship, "relationship", :relationships, "relationships"
            "relationship"
          when :path, "path", :paths, "paths"
            "path"
          when :fullpath, "fullpath", :fullpaths, "fullpaths"
            "fullpath"
          else
            "node"
        end
      end

      def get_uniqueness(uniqueness)
        case uniqueness
          when :nodeglobal, "node global", "nodeglobal", "node_global"
            "node global"
          when :nodepath, "node path", "nodepath", "node_path"
            "node path"
          when :noderecent, "node recent", "noderecent", "node_recent"
            "node recent"
          when :relationshipglobal, "relationship global", "relationshipglobal", "relationship_global"
            "relationship global"
          when :relationshippath, "relationship path", "relationshippath", "relationship_path"
            "relationship path"
          when :relationshiprecent, "relationship recent", "relationshiprecent", "relationship_recent"
            "relationship recent"
          else
            "none"
        end
      end

      def get_depth(depth)
        return nil if depth.nil?
        return 1 if depth.to_i == 0
        depth.to_i
      end

  end
end
