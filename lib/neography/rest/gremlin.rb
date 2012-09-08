module Neography
  class Rest
    class Gremlin
      include Neography::Rest::Helpers

      def initialize(connection)
        @connection = connection
      end

      def execute(script, parameters)
        options = {
          :body => {
            :script => script,
            :params => parameters,
          }.to_json,
          :headers => json_content_type
        }
        result = @connection.post(@connection.gremlin_path, options)
        result == "null" ? nil : result
      end

    end
  end
end
