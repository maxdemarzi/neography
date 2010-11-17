module Neography
  class Rest
    include HTTParty
    base_uri 'http://localhost:9999'
    format :json

    class << self

    def get_root
      rescue_ij { get('/') }
    end

      def create_node(*args)
        if args[0].respond_to?(:each_pair) && args[0] 
         options = { :body => args[0].to_json, :headers => {'Content-Type' => 'application/json'} } 
         rescue_ij { post("/node", options) }
        else
         rescue_ij { post("/node") }
        end
      end

      def get_node(id)
        rescue_ij { get("/node/#{id}") }
      end

      def reset_node_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        rescue_ij { put("/node/#{id}/properties", options) }
      end

      def get_node_properties(id, properties = nil)
        if properties.nil?
          rescue_ij { get("/node/#{id}/properties") }
        else
          node_properties = Hash.new 
          properties.to_a.each do |property| 
            value = rescue_ij { get("/node/#{id}/properties/#{property}") } 
            node_properties[property] = value unless value.nil?
          end
          return nil if node_properties.empty?
          node_properties
        end
      end

      def remove_node_properties(id, properties = nil)
        if properties.nil?
          rescue_ij { delete("/node/#{id}/properties") }
        else 
          properties.to_a.each do |property| 
            rescue_ij { delete("/node/#{id}/properties/#{property}") } 
          end
        end
      end

      def set_node_properties(id, properties)
          properties.each do |key, value| 
            options = { :body => value.to_json, :headers => {'Content-Type' => 'application/json'} } 
            rescue_ij { put("/node/#{id}/properties/#{key}", options) } 
          end
      end

      def delete_node(id)
        rescue_ij { delete("/node/#{id}") }
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

    end

  end
end