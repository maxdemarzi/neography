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

      # create is the same as new
      alias_method :create, :new

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
        begin
          get("/node/#{id}/properties")
        rescue 
          nil
        end
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

      def remove_properties(id)
        response = delete("/node/#{id}/properties")
        evaluate_response(response)
        response.parsed_response
      end

      def del(id)
        response = delete("/node/#{id}")
        evaluate_response(response)
        response.parsed_response
      end

      def del!(id)
        relationships = rels(id)
        relationships.each {|r| Relationship.del(r[:rel_id])}
        response = delete("/node/#{id}")
        evaluate_response(response)
        response.parsed_response
      end

      def exists?(id)
        load(id).nil? == false
      end

     def rels(id, dir=nil, types=nil)
       case dir
         when :incoming
           dir = "in"
         when :outgoing
           dir = "out"
         else
           dir = "all"
       end

       if types.nil?
         response = get("/node/#{id}/relationships/#{dir}")
       else
         response = get("/node/#{id}/relationships/#{dir}/#{types.to_a.join('&')}")
       end
        evaluate_response(response)
        build_rels(response)
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

     def build_rels(response)
       begin
         rels = response.parsed_response
         rels.each do |r|       
           r[:rel_id] = r["self"].split('/').last
           r[:start_node] = r["start"].split('/').last
           r[:end_node] = r["end"].split('/').last
         end
       rescue 
         rels = Array.new
       end
       rels
     end


    end
  end
end
