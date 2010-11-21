module Neography
  class Rest
    include HTTParty
    attr_accessor :protocol, :server, :port, :log_file, :log_enabled, :logger

      def initialize(protocol='http://', server='localhost', port=7474, log_file='neography.log', log_enabled=true)
        @protocol = protocol
        @server = server
        @port = port 
        @log_file = log_file
        @log_enabled = log_enabled
        @logger = Logger.new(@log_file) if @log_enabled
      end

      def configure(protocol, server, port)
        @protocol = protocol
        @server = server
        @port = port 
      end

      def configuration
        @protocol + @server + ':' + @port.to_s + "/db/data"
      end

      def get_root
        get('/') 
      end

      def create_node(*args)
        if args[0].respond_to?(:each_pair) && args[0] 
          options = { :body => args[0].to_json, :headers => {'Content-Type' => 'application/json'} } 
          post("/node", options) 
        else
          post("/node") 
        end
      end

      def get_node(id)
        get("/node/#{id}")
      end

      def reset_node_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        put("/node/#{id}/properties", options)
      end

      def get_node_properties(id, properties = nil)
        if properties.nil?
          get("/node/#{id}/properties")
        else
          node_properties = Hash.new 
          properties.to_a.each do |property| 
            value = get("/node/#{id}/properties/#{property}")
            node_properties[property] = value unless value.nil?
          end
          return nil if node_properties.empty?
          node_properties
        end
      end

      def remove_node_properties(id, properties = nil)
        if properties.nil?
          delete("/node/#{id}/properties")
        else 
          properties.to_a.each do |property| 
            delete("/node/#{id}/properties/#{property}") 
          end
        end
      end

      def set_node_properties(id, properties)
          properties.each do |key, value| 
            options = { :body => value.to_json, :headers => {'Content-Type' => 'application/json'} } 
            put("/node/#{id}/properties/#{key}", options) 
          end
      end

      def delete_node(id)
        delete("/node/#{id}")
      end

      def create_relationship(type, from, to, props = nil)
         options = { :body => {:to => self.configuration + "/node/#{to}", :data => props, :type => type }.to_json, :headers => {'Content-Type' => 'application/json'} } 
         post("/node/#{from}/relationships", options)
      end

      def reset_relationship_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        put("/relationship/#{id}/properties", options)
      end

      def get_relationship_properties(id, properties = nil)
        if properties.nil?
          get("/relationship/#{id}/properties")
        else
          relationship_properties = Hash.new 
          properties.to_a.each do |property| 
            value = get("/relationship/#{id}/properties/#{property}")
            relationship_properties[property] = value unless value.nil?
          end
          return nil if relationship_properties.empty?
          relationship_properties
        end
      end

      def remove_relationship_properties(id, properties = nil)
        if properties.nil?
          delete("/relationship/#{id}/properties")
        else 
          properties.to_a.each do |property| 
            delete("/relationship/#{id}/properties/#{property}")
          end
        end
      end

      def set_relationship_properties(id, properties)
          properties.each do |key, value| 
            options = { :body => value.to_json, :headers => {'Content-Type' => 'application/json'} } 
            put("/relationship/#{id}/properties/#{key}", options)
          end
      end

      def delete_relationship(id)
        delete("/relationship/#{id}")
      end

      def get_node_relationships(id, dir=nil, types=nil)
        dir = get_dir(dir)

        if types.nil?
          node_relationships = get("/node/#{id}/relationships/#{dir}") || Array.new
        else
          node_relationships = get("/node/#{id}/relationships/#{dir}/#{types.to_a.join('&')}") || Array.new
        end
        return nil if node_relationships.empty?
        node_relationships
      end

      def delete_node!(id)
        relationships = get_node_relationships(id)
        relationships.each { |r| delete_relationship(r["self"].split('/').last) } unless relationships.nil?
        delete("/node/#{id}")
      end

      def list_indexes
        get("/index")
      end

      def add_to_index(key, value, id)
        options = { :body => (self.configuration + "/node/#{id}").to_json, :headers => {'Content-Type' => 'application/json'} } 
        post("/index/node/#{key}/#{value}", options)
      end

      def remove_from_index(key, value, id)
        delete("/index/node/#{key}/#{value}/#{id}")
      end

      def get_index(key, value)
        index = get("/index/node/#{key}/#{value}") || Array.new
        return nil if index.empty?
        index
      end

      def traverse(id, return_type, description)
        options = { :body => {"order" => get_order(description["order"]), 
                              "uniqueness" => get_uniqueness(description["uniqueness"]), 
                              "relationships" => description["relationships"], 
                              "prune evaluator" => description["prune evaluator"], 
                              "return filter" => description["return filter"], 
                              "max depth" => get_depth(description["depth"]), }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        traversal = post("/node/#{id}/traverse/#{get_type(return_type)}", options) || Array.new
      end

      def get_path(from, to, relationships, depth=1, algorithm="shortestPath")
        options = { :body => {"to" => self.configuration + "/node/#{to}", "relationships" => relationships, "max depth" => depth, "algorithm" => get_algorithm(algorithm) }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        path = post("/node/#{from}/path", options) || Hash.new
      end

      def get_paths(from, to, relationships, depth=1, algorithm="allPaths")
        options = { :body => {"to" => self.configuration + "/node/#{to}", "relationships" => relationships, "max depth" => depth, "algorithm" => get_algorithm(algorithm) }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        paths = post("/node/#{from}/paths", options) || Array.new
      end

      private

      def evaluate_response(response)
        code = response.code
        body = response.body
     
        case code 
          when 200 
            @logger.debug "OK" if @log_enabled
            response
          when 201
            @logger.debug "OK, created #{body}" if @log_enabled
            response
          when 204  
            @logger.debug "OK, no content returned" if @log_enabled
            nil
          when 400
            @logger.error "Invalid data sent #{body}"  if @log_enabled
            nil
          when 404
            @logger.error "#{body}" if @log_enabled
            nil
          when 409
            @logger.error "Node could not be deleted (still has relationships?)" if @log_enabled
            nil
        end
      end

       def get(path,options={})
          evaluate_response(HTTParty.get(configuration + path, options))
       end

       def post(path,options={})
          evaluate_response(HTTParty.post(configuration + path, options))
       end

       def put(path,options={})
          evaluate_response(HTTParty.put(configuration + path, options))
       end

       def delete(path,options={})
          evaluate_response(HTTParty.delete(configuration + path, options))
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
          when :node, "nodes", :nodes, "nodes"
            "node"
          when :relationship, "relationship", :relationships, "relationships"
            "relationship"
          else
            "path"
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
        return 1 if depth.to_i == 0
        depth.to_i
      end

  end
end