module Neography
  class Rest
    include HTTParty
    base_uri Neography::Config.to_s
    format :json

    class << self

      def get_root
        rescue_ij { get('/db/data/') }
      end

      def create_node(*args)
        if args[0].respond_to?(:each_pair) && args[0] 
         options = { :body => args[0].to_json, :headers => {'Content-Type' => 'application/json'} } 
         rescue_ij { post("/db/data/node", options) }
        else
         rescue_ij { post("/db/data/node") }
        end
      end

      def get_node(id)
        rescue_ij { get("/db/data/node/#{id}") }
      end

      def reset_node_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        rescue_ij { put("/db/data/node/#{id}/properties", options) }
      end

      def get_node_properties(id, properties = nil)
        if properties.nil?
          rescue_ij { get("/db/data/node/#{id}/properties") }
        else
          node_properties = Hash.new 
          properties.to_a.each do |property| 
            value = rescue_ij { get("/db/data/node/#{id}/properties/#{property}") } 
            node_properties[property] = value unless value.nil?
          end
          return nil if node_properties.empty?
          node_properties
        end
      end

      def remove_node_properties(id, properties = nil)
        if properties.nil?
          rescue_ij { delete("/db/data/node/#{id}/properties") }
        else 
          properties.to_a.each do |property| 
            rescue_ij { delete("/db/data/node/#{id}/properties/#{property}") } 
          end
        end
      end

      def set_node_properties(id, properties)
          properties.each do |key, value| 
            options = { :body => value.to_json, :headers => {'Content-Type' => 'application/json'} } 
            rescue_ij { put("/db/data/node/#{id}/properties/#{key}", options) } 
          end
      end

      def delete_node(id)
        rescue_ij { delete("/db/data/node/#{id}") }
      end

      def create_relationship(type, from, to, props = nil)
         options = { :body => {:to => Neography::Config.to_s + "/node/#{to}", :data => props, :type => type }.to_json, :headers => {'Content-Type' => 'application/json'} } 
         rescue_ij { post("/db/data/node/#{from}/relationships", options) }
      end

      def reset_relationship_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        rescue_ij { put("/db/data/relationship/#{id}/properties", options) }
      end

      def get_relationship_properties(id, properties = nil)
        if properties.nil?
          rescue_ij { get("/db/data/relationship/#{id}/properties") }
        else
          relationship_properties = Hash.new 
          properties.to_a.each do |property| 
            value = rescue_ij { get("/db/data/relationship/#{id}/properties/#{property}") } 
            relationship_properties[property] = value unless value.nil?
          end
          return nil if relationship_properties.empty?
          relationship_properties
        end
      end

      def remove_relationship_properties(id, properties = nil)
        if properties.nil?
          rescue_ij { delete("/db/data/relationship/#{id}/properties") }
        else 
          properties.to_a.each do |property| 
            rescue_ij { delete("/db/data/relationship/#{id}/properties/#{property}") } 
          end
        end
      end

      def set_relationship_properties(id, properties)
          properties.each do |key, value| 
            options = { :body => value.to_json, :headers => {'Content-Type' => 'application/json'} } 
            rescue_ij { put("/db/data/relationship/#{id}/properties/#{key}", options) } 
          end
      end

      def delete_relationship(id)
        rescue_ij { delete("/db/data/relationship/#{id}") }
      end

      def get_node_relationships(id, dir=nil, types=nil)
        dir = get_dir(dir)

        if types.nil?
          node_relationships = rescue_ij { get("/db/data/node/#{id}/relationships/#{dir}") } || Array.new
        else
          node_relationships = rescue_ij { get("/db/data/node/#{id}/relationships/#{dir}/#{types.to_a.join('&')}") } || Array.new
        end
        return nil if node_relationships.empty?
        node_relationships
      end

      def delete_node!(id)
        relationships = get_node_relationships(id)
        relationships.each { |r| delete_relationship(r["self"].split('/').last) } unless relationships.nil?
        rescue_ij { delete("/db/data/node/#{id}") }
      end

      def list_indexes
        rescue_ij { get("/db/data/index") }
      end

      def add_to_index(key, value, id)
        options = { :body => (Neography::Config.to_s + "/node/#{id}").to_json, :headers => {'Content-Type' => 'application/json'} } 
        rescue_ij { post("/db/data/index/node/#{key}/#{value}", options) }
      end

      def remove_from_index(key, value, id)
        rescue_ij { delete("/db/data/index/node/#{key}/#{value}/#{id}") }
      end

      def get_index(key, value)
        index = rescue_ij { get("/db/data/index/node/#{key}/#{value}") } || Array.new
        return nil if index.empty?
        index
      end

      def get_path(from, to, relationships, depth=1, algorithm="allPaths")
        options = { :body => {"to" => Neography::Config.to_s + "/node/#{to}", "relationships" => relationships, "max depth" => depth, "algorithm" => get_algorithm(algorithm) }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        path = rescue_ij { post("/db/data/node/#{from}/path", options) } || Hash.new
      end

      def get_paths(from, to, relationships, depth=1, algorithm="allPaths")
        options = { :body => {"to" => Neography::Config.to_s + "/node/#{to}", "relationships" => relationships, "max depth" => depth, "algorithm" => get_algorithm(algorithm) }.to_json, :headers => {'Content-Type' => 'application/json'} } 
        paths = rescue_ij { post("/db/data/node/#{from}/paths", options) } || Array.new
      end

     private

      # Rescue from Invalid JSON error thrown by Crack Gem

      def rescue_ij(&block) 
        begin
          response = yield
          response = response.parsed_response
        rescue 
          response = nil
        end
        response
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


    end

  end
end