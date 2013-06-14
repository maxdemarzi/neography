module Neography
  class Rest
    class RelationshipTypes
      extend Neography::Rest::Paths

      add_path :all,    "/relationship/types"
      
      def initialize(connection)
        @connection = connection
      end
            
      def list
        @connection.get(all_path)
      end

    end
  end
end
