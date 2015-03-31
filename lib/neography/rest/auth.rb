module Neography
  class Rest
    module Auth
      include Neography::Rest::Helpers
      
      def change_password(password)
        options = {
          :body => { :password => password }.to_json,
          :headers => json_content_type
        }
        @connection.post("/user/neo4j/password", options)
      end
      
    end
  end
end  
  