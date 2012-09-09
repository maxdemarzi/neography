module Neography
  class Rest
    class NodeAutoIndexes < AutoIndexes
      include Neography::Rest::Paths

      add_path :key_value,        "/index/auto/node/:key/:value"
      add_path :query_index,      "/index/auto/node/?query=:query"
      add_path :index_status,     "/index/auto/node/status"
      add_path :index_properties, "/index/auto/node/properties"
      add_path :index_property,   "/index/auto/node/properties/:property"

    end
  end
end
