module Neography
  class Relationship < PropertyContainer
    attr_reader :start, :end, :type

    def initialize(hash=nil)
      super(hash)
      @start = hash["start"].split('/').last
      @end = hash["end"].split('/').last
      @type = hash["type"]
    end

  end
end