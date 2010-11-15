module Neography
  class Node
    include HTTParty
    base_uri 'http://localhost:9999'
    format :json

    class << self

      def new(*args)
        if args[0].respond_to?(:each_pair) && args[0] 
         options = { :body => args[0].to_json, :headers => {'Content-Type' => 'application/json'} } 
         response = post("/node", options)
         evaluate_response(response)
         build_node(response)
        else
         response = post("/node")
         evaluate_response(response)
         build_node(response)
        end
      end

      def load(id)
         begin
           response = get("/node/#{id}")
           evaluate_response(response)
           build_node(response)
         rescue 
           nil
         end
      end

      def properties(id)
        get("/node/#{id}/properties")
      end

      def set_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        response = put("/node/#{id}/properties", options)
        evaluate_response(response)
        response.parsed_response
      end

      def remove_property(id, property)
        response = delete("/node/#{id}/properties/#{property}")
        evaluate_response(response)
        response.parsed_response
      end

      def del(id)
        response = delete("/node/#{id}")
        evaluate_response(response)
        response.parsed_response
      end

     private

     def build_node(response)
       begin
         node = response.parsed_response["data"]
       rescue 
         node = Array.new
       end
       node[:neo_id] = response.parsed_response["self"].split('/').last
       node
     end

    end
  end
end
