module Neography
  class Rest
    class Cypher
      include Neography::Rest::Helpers

      def initialize(connection)
        @connection = connection
      end

      def query(query, parameters = {})
        options = {
          :body => {
            :query => query,
            :params => parameters
          }.to_json,
          :headers => json_content_type.merge({'Accept' => 'application/json;stream=true'})
        }

        @connection.post(@connection.cypher_path, options)
      end

    end
  end
end
