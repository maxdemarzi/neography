module Neography

  class << self

    def ref_node(this_db = Neography::Rest.new)
      this_db.get_root
    end

  end
end