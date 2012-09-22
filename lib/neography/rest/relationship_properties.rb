module Neography
  class Rest
    class RelationshipProperties < Properties
      extend Neography::Rest::Paths

      add_path :all,    "/relationship/:id/properties"
      add_path :single, "/relationship/:id/properties/:property"

    end
  end
end
