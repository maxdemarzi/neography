module Neography
  module NodeRelationship

    def rels(*type)
      RelationshipTraverser.new(self, type, :both)
    end

    def rel(dir, type)
      RelationshipTraverser.new(self, type, dir)
    end

    def rel? (type=nil, dir=:both)
      self.neo_server.get_node_relationships(self, dir, type).empty? 
    end

  end
end