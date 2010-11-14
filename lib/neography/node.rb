module Neography
  class Node
    include HTTParty
    base_uri 'http://localhost:9999'
    format :json

    class << self

      def new(*args)
        if args[0].respond_to?(:each_pair) && args[0] 
         headers 'Content-Type' => 'application/json'
         response = post("/node", :body => args[0].to_json)
         evaluate_response(response)
         response.parsed_response
        else
         response = post("/node")
         evaluate_response(response)
         response.parsed_response
        end
      end

      def get_node(id)
         begin
           response = get("/node/#{id}")
           evaluate_response(response)
           response.parsed_response
         rescue 
           nil
         end
      end

      def properties(id)
        get("/node/#{id}/properties")
      end

      def set_properties(id, properties)
        begin
          response = put("/node/#{id}/properties", :body => properties.to_json)
           evaluate_response(response)
           response.parsed_response
         rescue 
           nil
         end
      end

    end
  end
end
