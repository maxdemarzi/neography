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

      def set_node_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        rescue_ij { put("/node/#{id}/properties", options) }
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