module Neography
  class Neo
    include HTTParty

    base_uri 'http://localhost:9999'

    def self.root_node
      get('/')
    end

  end
end
