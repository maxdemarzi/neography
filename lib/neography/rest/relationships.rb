module Neography
  class Rest
    module Relationships
      include Neography::Rest::Helpers
        
      def get_relationship(id)
        @connection.get("/relationship/%{id}" % {:id => get_id(id)})
      end

      def delete_relationship(id)
        @connection.delete("/relationship/%{id}" % {:id => get_id(id)})
      end

    end
  end
end
