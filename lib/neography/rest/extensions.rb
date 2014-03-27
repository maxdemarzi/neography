module Neography
  class Rest
    module Extensions
      include Neography::Rest::Helpers
    
      def get_extension(path)
        @connection.get(path)
      end

      def post_extension(path, body = {}, headers = nil)
        options = {
          :body => headers.nil? ? body.to_json : body,
          :headers => headers || json_content_type.merge({'Accept' => 'application/json;stream=true'})
        }

        @connection.post(path, options)
      end

    end
  end
end
