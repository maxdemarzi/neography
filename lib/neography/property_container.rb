module Neography
  class PropertyContainer < OpenStruct
    attr_reader :neo_id

    def initialize(hash=nil)
      @table = {}
      unless hash.nil?
        if hash["self"] # coming from REST API
          @neo_id = hash["self"].split('/').last
          data = hash["data"]
        elsif hash.is_a? Neography::Node # is already a Neography::Node
          @neo_id = hash.neo_id
          data = Hash[*hash.attributes.collect{|x| [x.to_sym, hash.send(x)]}.flatten]
        elsif hash["data"] # coming from CYPHER
          @neo_id = hash["data"].first.first["self"].split('/').last
          data = hash["data"].first.first["data"]
        end
      else
        data = []
      end

      for k,v in data
        new_ostruct_member(k.to_sym, v)
      end
    end

  end
end
