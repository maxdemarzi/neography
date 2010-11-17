module Neography
  class Rest
    include HTTParty
    base_uri 'http://localhost:9999'
    format :json

    class << self

    def get_root
      rescue_404(get('/'))
    end

      def create_node(*args)
        if args[0].respond_to?(:each_pair) && args[0] 
         options = { :body => args[0].to_json, :headers => {'Content-Type' => 'application/json'} } 
         rescue_404(post("/node", options))
        else
         rescue_404(post("/node"))
        end
      end


     private

      def rescue_404(response)
        begin
          response = response.parsed_response
        rescue 
          response = nil
        end
        response
      end

    end

  end
end