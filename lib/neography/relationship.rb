module Neography
  class Relationship
    include HTTParty
    base_uri Neography::Config.to_s
    format :json

    class << self

      def new(type, from, to, props = nil)
         options = { :body => {:to => Neography::Config.to_s + "/node/#{to[:neo_id]}", :data => props, :type => type }.to_json, :headers => {'Content-Type' => 'application/json'} } 
         response = post("/node/#{from[:neo_id]}/relationships", options)
         evaluate_response(response)
         build_relationship(response)
      end

      def load(id)
         begin
           response = get("/node/#{id}")
           evaluate_response(response)
           build_relationship(response)
         rescue 
           nil
         end
      end

      def properties(id)
        get("/relationship/#{id}/properties")
      end

      def set_properties(id, properties)
        options = { :body => properties.to_json, :headers => {'Content-Type' => 'application/json'} } 
        response = put("/relationship/#{id}/properties", options)
        evaluate_response(response)
        response.parsed_response
      end

      def remove_property(id, property)
        response = delete("/relationship/#{id}/properties/#{property}")
        evaluate_response(response)
        response.parsed_response
      end

      def remove_properties(id)
        response = delete("/relationship/#{id}/properties")
        evaluate_response(response)
        response.parsed_response
      end

      def del(id)
        response = delete("/relationship/#{id}")
        evaluate_response(response)
        response.parsed_response
      end

     private

     def build_relationship(response)
       begin
         relationship = response.parsed_response["data"]
       rescue 
         relationship = Array.new
       end
       relationship[:rel_id] = response.parsed_response["self"].split('/').last
       relationship
     end

    end
  end
end
