module Neography
  
  class Rest
    include HTTParty
    USER_AGENT = "Neography/#{Neography::VERSION}"
    
    attr_accessor :protocol, :server, :port, :directory, :cypher_path, :gremlin_path, :log_file, :log_enabled, :logger, :max_threads, :authentication, :username, :password, :parser

      def initialize(options=ENV['NEO4J_URL'] || {})
        init = {:protocol       => Neography::Config.protocol, 
                :server         => Neography::Config.server, 
                :port           => Neography::Config.port, 
                :directory      => Neography::Config.directory,
                :cypher_path    => Neography::Config.cypher_path,
                :gremlin_path   => Neography::Config.gremlin_path, 
                :log_file       => Neography::Config.log_file, 
                :log_enabled    => Neography::Config.log_enabled, 
                :max_threads    => Neography::Config.max_threads,
                :authentication => Neography::Config.authentication,
                :username       => Neography::Config.username,
                :password       => Neography::Config.password,
                :parser         => Neography::Config.parser
                }

        unless options.respond_to?(:each_pair)
          url = URI.parse(options)
          options = Hash.new
          options[:protocol] = url.scheme + "://"
          options[:server] = url.host
          options[:port] = url.port
          options[:directory] = url.path
          options[:username] = url.user
          options[:password] = url.password
          options[:authentication] = 'basic' unless url.user.nil?
        end

        init.merge!(options)

        @protocol       = init[:protocol]
        @server         = init[:server]
        @port           = init[:port]
        @directory      = init[:directory]
        @cypher_path    = init[:cypher_path]
        @gremlin_path   = init[:gremlin_path]
        @log_file       = init[:log_file]
        @log_enabled    = init[:log_enabled]
        @logger         = Logger.new(@log_file) if @log_enabled
        @max_threads    = init[:max_threads]
        @authentication = Hash.new
        @authentication = {"#{init[:authentication]}_auth".to_sym => {:username => init[:username], :password => init[:password]}} unless init[:authentication].empty?
        @parser         = init[:parser]
        @user_agent     = {"User-Agent" => USER_AGENT}
      end

      def configure(protocol, server, port, directory)
        @protocol = protocol
        @server = server
        @port = port 
        @directory = directory
      end

      def configuration
        @protocol + @server + ':' + @port.to_s + @directory + "/db/data"
      end

      def get_root
        get("/node/#{get_id(get('/')["reference_node"])}") 
      end

      def create_node(*args)
        if args[0].respond_to?(:each_pair) && args[0] 
          options = { :body => args[0].delete_if { |k, v| v.nil? }.to_json, :headers => {'Content-Type' => 'application/json'} } 
          post("/node", options) 
        else
          post("/node") 
        end
      end

      def create_nodes(nodes)
        nodes = Array.new(nodes) if nodes.kind_of? Fixnum
        created_nodes = Array.new
        nodes.each do |node|
            created_nodes <<  create_node(node)
        end
        created_nodes
      end

      def create_nodes_threaded(nodes)
        nodes = Array.new(nodes) if nodes.kind_of? Fixnum

        node_queue = Queue.new
        thread_pool = []
        responses = Queue.new

        nodes.each do |node|
          node_queue.push node
        end

        [nodes.size, @max_threads].min.times do
          thread_pool << Thread.new do
            until node_queue.empty? do
              node = node_queue.pop
              if node.respond_to?(:each_pair) 
                responses.push( post("/node", { :body => node.to_json, :headers => {'Content-Type' => 'application/json'} } ) )
              else
                responses.push( post("/node") )
              end
            end 
            self.join
          end
        end

        created_nodes = Array.new

        while created_nodes.size < nodes.size 
          created_nodes << responses.pop
        end
        created_nodes
      end

#  This is not yet implemented in the REST API
#
#      def get_all_node
#        puts "get all nodes"
#        get("/nodes/")
#      end

      def get_node(id)
        get("/node/#{get_id(id)}")
      end

      def get_nodes(*nodes)
        gotten_nodes = Array.new
        Array(nodes).flatten.each do |node|
            gotten_nodes <<  get_node(node)
        end
        gotten_nodes
      end

      def reset_node_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        put("/node/#{get_id(id)}/properties", options)
      end

      def get_node_properties(id, properties = nil)
        if properties.nil?
          get("/node/#{get_id(id)}/properties")
        else
          node_properties = Hash.new 
          Array(properties).each do |property| 
            value = get("/node/#{get_id(id)}/properties/#{property}")
            node_properties[property] = value unless value.nil?
          end
          return nil if node_properties.empty?
          node_properties
        end
      end

      def remove_node_properties(id, properties = nil)
        if properties.nil?
          delete("/node/#{get_id(id)}/properties")
        else 
          Array(properties).each do |property| 
            delete("/node/#{get_id(id)}/properties/#{property}") 
          end
        end
      end

      def set_node_properties(id, properties)
          properties.each do |key, value| 
            options = { :body => value.to_json, :headers => {'Content-Type' => 'application/json'} } 
            put("/node/#{get_id(id)}/properties/#{key}", options) 
          end
      end

      def delete_node(id)
        delete("/node/#{get_id(id)}")
      end

      def create_relationship(type, from, to, props = nil)
         options = { :body => {:to => self.configuration + "/node/#{get_id(to)}", :data => props, :type => type }.to_json, :headers => {'Content-Type' => 'application/json'} } 
         post("/node/#{get_id(from)}/relationships", options)
      end

      def create_unique_relationship(index, key, value, type, from, to)
        body = {:key=>key,:value=>value, :type => type }
        body[:start] = self.configuration + "/node/#{get_id(from)}"
        body[:end] = self.configuration + "/node/#{get_id(to)}"
        options = { :body => body.to_json, :headers => {'Content-Type' => 'application/json'} } 
        post("/index/relationship/#{index}?unique", options) 
      end

      def get_relationship(id)
        get("/relationship/#{get_id(id)}")
      end

      def get_relationship_start_node(rel)
        get_node(rel["start"])
      end
      
      def get_relationship_end_node(rel)
        get_node(rel["end"])
      end
      
      def reset_relationship_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        put("/relationship/#{get_id(id)}/properties", options)
      end

      def get_relationship_properties(id, properties = nil)
        if properties.nil?
          get("/relationship/#{get_id(id)}/properties")
        else
          relationship_properties = Hash.new 
          Array(properties).each do |property| 
            value = get("/relationship/#{get_id(id)}/properties/#{property}")
            relationship_properties[property] = value unless value.nil?
          end
          return nil if relationship_properties.empty?
          relationship_properties
        end
      end

      def remove_relationship_properties(id, properties = nil)
        if properties.nil?
          delete("/relationship/#{get_id(id)}/properties")
        else 
          Array(properties).each do |property| 
            delete("/relationship/#{get_id(id)}/properties/#{property}")
          end
        end
      end

      def set_relationship_properties(id, properties)
          properties.each do |key, value| 
            options = { :body => value.to_json, :headers => {'Content-Type' => 'application/json'} } 
            put("/relationship/#{get_id(id)}/properties/#{key}", options)
          end
      end

      def delete_relationship(id)
        delete("/relationship/#{get_id(id)}")
      end

      def get_node_relationships(id, dir=nil, types=nil)
        dir = get_dir(dir)

        if types.nil?
          node_relationships = get("/node/#{get_id(id)}/relationships/#{dir}") || Array.new
        else
          node_relationships = get("/node/#{get_id(id)}/relationships/#{dir}/#{Array(types).join('&')}") || Array.new
        end
        return nil if node_relationships.empty?
        node_relationships
      end

      def delete_node!(id)
        relationships = get_node_relationships(get_id(id))
        relationships.each { |r| delete_relationship(r["self"].split('/').last) } unless relationships.nil?
        delete("/node/#{get_id(id)}")
      end

      def list_node_indexes
        get("/index/node")
      end

      def create_node_index(name, type = "exact", provider = "lucene")
        options = { :body => ({:name => name, :config => {:type => type, :provider => provider}}).to_json, :headers => {'Content-Type' => 'application/json'} } 
        post("/index/node", options)
      end

      def create_node_auto_index(type = "exact", provider = "lucene")
        create_node_index("node_auto_index", type, provider)
      end

      def add_node_to_index(index, key, value, id)
        options = { :body => ({:uri =>  self.configuration + "/node/#{get_id(id)}", :key => key, :value => value }).to_json, :headers => {'Content-Type' => 'application/json'} } 
        post("/index/node/#{index}", options)
      end

      def create_unique_node(index, key, value, props={})
        options = { :body => ({:properties=>props, :key => key, :value => value }).to_json, :headers => {'Content-Type' => 'application/json'} } 
        post("/index/node/#{index}?unique", options) 
      end

      def remove_node_from_index(*args)
        case args.size
          when 4 then delete("/index/node/#{args[0]}/#{args[1]}/#{args[2]}/#{get_id(args[3])}")
          when 3 then delete("/index/node/#{args[0]}/#{args[1]}/#{get_id(args[2])}")
          when 2 then delete("/index/node/#{args[0]}/#{get_id(args[1])}")
        end
      end

      def get_node_index(index, key, value)
        index = get("/index/node/#{index}/#{key}/#{value}") || Array.new
        return nil if index.empty?
        index
      end

      def get_node_auto_index(key, value)
        index = get("/index/auto/node/#{key}/#{value}") || Array.new
        return nil if index.empty?
        index
      end

      def find_node_auto_index(*args)
        case args.size
          when 2 then index = get("/index/auto/node/#{args[0]}/#{args[1]}") || Array.new
          when 1 then index = get("/index/auto/node/?query=#{args[0]}") || Array.new
        end
        return nil if index.empty?
        index
      end

      def find_node_index(*args)
        case args.size
          when 3 then index = get("/index/node/#{args[0]}/#{args[1]}/#{args[2]}") || Array.new
          when 2 then index = get("/index/node/#{args[0]}?query=#{args[1]}") || Array.new
        end
        return nil if index.empty?
        index
      end

      alias_method :list_indexes, :list_node_indexes
      alias_method :add_to_index, :add_node_to_index
      alias_method :remove_from_index, :remove_node_from_index
      alias_method :get_index, :get_node_index

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

      def get_node_auto_index_status
        get("/index/auto/node/status")
      end

      def get_relationship_auto_index_status
        get("/index/auto/relationship/status")
      end

      def set_node_auto_index_status(change_to = true)
        options = { :body => change_to.to_json, :headers => {'Content-Type' => 'application/json'} }
        put("/index/auto/node/status", options)
      end

      def set_relationship_auto_index_status(change_to = true)
        options = { :body => change_to.to_json, :headers => {'Content-Type' => 'application/json'} }
        put("/index/auto/relationship/status", options)
      end

      def get_node_auto_index_properties
        get("/index/auto/node/properties")
      end

      def get_relationship_auto_index_properties
        get("/index/auto/relationship/properties")
      end

      def add_node_auto_index_property(property)
        options = { :body => property, :headers => {'Content-Type' => 'application/json'} }
        post("/index/auto/node/properties", options)
      end

      def remove_node_auto_index_property(property)
        delete("/index/auto/node/properties/#{property}")
      end

      def add_relationship_auto_index_property(property)
        options = { :body => property, :headers => {'Content-Type' => 'application/json'} }
        post("/index/auto/relationship/properties", options)
      end

      def remove_relationship_auto_index_property(property)
        delete("/index/auto/relationship/properties/#{property}")
      end

      def traverse(id, return_type, description)
        options = { :body => {"order" => get_order(description["order"]), 
                              "uniqueness" => get_uniqueness(description["uniqueness"]), 
                              "relationships" => description["relationships"], 
                              "prune_evaluator" => description["prune evaluator"], 
                              "return_filter" => description["return filter"], 
                              "max_depth" => get_depth(description["depth"]), }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        traversal = post("/node/#{get_id(id)}/traverse/#{get_type(return_type)}", options) || Array.new
      end

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

      def execute_query(query, params = {})
          options = { :body => {:query => query, :params => params}.to_json, :headers => {'Content-Type' => 'application/json', 'Accept' => 'application/json;stream=true'} }
          result = post(@cypher_path, options)
      end
      
      def execute_script(script, params = {})
        options = { :body => {:script => script, :params => params}.to_json , :headers => {'Content-Type' => 'application/json'} }
        result = post(@gremlin_path, options)
        result == "null" ? nil : result
      end

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

      def merge_options(options)
        merged_options = options.merge!(@authentication).merge!(@parser)
        merged_options[:headers].merge!(@user_agent) if merged_options[:headers]
        merged_options
      end
            
      private

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
            {:method => "POST", :to => @gremlin_path, :body => {:script => args[1], :params => args[2]}}
          when :execute_query
            if args[2]
              {:method => "POST", :to => @cypher_path, :body => {:query => args[1], :params => args[2]}}
            else
              {:method => "POST", :to => @cypher_path, :body => {:query => args[1]}}
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

      def evaluate_response(response)
        code = response.code
        body = response.body
        case code 
          when 200 
            @logger.debug "OK" if @log_enabled
            response.parsed_response
          when 201
            @logger.debug "OK, created #{body}" if @log_enabled
            response.parsed_response
          when 204  
            @logger.debug "OK, no content returned" if @log_enabled
            nil
          when 400
            @logger.error "Invalid data sent #{body}"  if @log_enabled
            nil
          when 404
            @logger.error "Not Found #{body}" if @log_enabled
            nil
          when 409
            @logger.error "Node could not be deleted (still has relationships?)" if @log_enabled
            nil
        end
      end

       def get(path,options={})
          evaluate_response(HTTParty.get(configuration + URI.encode(path), merge_options(options)))
       end



       def post(path,options={})
          evaluate_response(HTTParty.post(configuration + URI.encode(path), merge_options(options)))
       end

       def put(path,options={})
          evaluate_response(HTTParty.put(configuration + URI.encode(path), merge_options(options)))
       end

       def delete(path,options={})
          evaluate_response(HTTParty.delete(configuration + URI.encode(path), merge_options(options)))
       end

      def get_id(id)
        case id
          when Array
            get_id(id.first)
          when Hash
            id["self"].split('/').last
          when String
            id.split('/').last
          when Neography::Node, Neography::Relationship
            id.neo_id
          else
            id
          end 
      end

      def get_dir(dir)
        case dir
          when :incoming, "incoming", :in, "in"
            "in"
          when :outgoing, "outgoing", :out, "out"
            "out"
          else
            "all"
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
