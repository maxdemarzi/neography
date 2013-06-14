module Neography
  class Rest
    class RelationshipTypes < Properties
      extend Neography::Rest::Paths

      add_path :all,    "/relationship/types"
      
      def list
        @connection.get(all_path)
      end

    end
  end
end
