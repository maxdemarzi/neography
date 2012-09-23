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

    # the arguments are either a Rest instance, or something else
    def self.split_args(*args)
      db = other = nil

      args.each do |arg|
        case arg
        when Rest
          db = arg
        else
          other = arg
        end
      end
      db ||= Neography::Rest.new

      [ db, other ]
    end

  end
end
