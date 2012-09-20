module Neography
  class Rest
    class RelationshipAutoIndexes < AutoIndexes
      extend Neography::Rest::Paths

      add_path :key_value,        "/index/auto/relationship/:key/:value"
      add_path :query_index,      "/index/auto/relationship/?query=:query"
      add_path :index_status,     "/index/auto/relationship/status"
      add_path :index_properties, "/index/auto/relationship/properties"
      add_path :index_property,   "/index/auto/relationship/properties/:property"

    end
  end
end
