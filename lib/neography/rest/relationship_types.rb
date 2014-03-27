module Neography
  class Rest
    module RelationshipTypes
                  
      def list_relationship_types
        @connection.get("/relationship/types")
      end

    end
  end
end
