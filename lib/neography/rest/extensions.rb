module Neography
  class Rest
    class Extensions
      include Neography::Rest::Helpers

      def initialize(connection)
        @connection = connection
      end

      def get(path)
        @connection.get(path)
      end

      def post(path, body = {}, headers = nil)
        options = {
          :body => body.to_json,
          :headers => headers || json_content_type.merge({'Accept' => 'application/json;stream=true'})
        }

        @connection.post(path, options)
      end

    end
  end
end
