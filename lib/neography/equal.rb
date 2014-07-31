module Neography

  # == This mixin is used for both nodes and relationships to decide if two entities are equal or not.
  #
  module Equal
    def eql?(o)
      return false unless o.respond_to?(:neo_id)
      o.neo_id == neo_id
    end

    def ==(o)
      eql?(o)
    end

  end

end