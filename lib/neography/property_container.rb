module Neography
  class PropertyContainer < OpenStruct
    attr_reader :neo_id

    def initialize(hash=nil)
      @table = {}
      if hash
        @neo_id = hash["self"].split('/').last
        for k,v in hash["data"]
          @table[k.to_sym] = v
          new_ostruct_member(k)
        end
      end
    end

  end
end
