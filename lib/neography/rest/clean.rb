module Neography
  class Rest
    class Clean
      include Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :clean, "/cleandb/secret-key"

      def initialize(connection)
        @connection = connection
      end

      def execute
        @connection.delete(clean_path)
      end

    end
  end
end
