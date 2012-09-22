module Neography
  class Rest
    class NodeProperties < Properties
      extend Neography::Rest::Paths

      add_path :all,    "/node/:id/properties"
      add_path :single, "/node/:id/properties/:property"

    end
  end
end
