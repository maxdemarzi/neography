module Neography
  class Rest
    class Relationships
      extend Neography::Rest::Paths
      include Neography::Rest::Helpers

      add_path :base,   "/relationship/:id"

      def initialize(connection)
        @connection = connection
      end

      def get(id)
        @connection.get(base_path(:id => get_id(id)))
      end

      def delete(id)
        @connection.delete(base_path(:id => get_id(id)))
      end

    end
  end
end
