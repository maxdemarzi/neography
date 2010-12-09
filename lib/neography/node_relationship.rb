module Neography
  module NodeRelationship

    def outgoing(types=nil)
      if types
        NodeTraverser.new(self).outgoing(types)
      else
        NodeTraverser.new(self).outgoing(types).collect {|n| n}
      end
    end

    def incoming(types=nil)
      if types
        NodeTraverser.new(self).incoming(types)
      else
        NodeTraverser.new(self).incoming(types).collect {|n| n}
      end
    end

    def both(types=nil)
      if types
        NodeTraverser.new(self).both(types)
      else
        NodeTraverser.new(self).both(types).collect {|n| n}
      end
    end

    def rels(*types)
      Neography::RelationshipTraverser.new(self, types, :both)
    end

    def rel(dir, type)
      Neography::RelationshipTraverser.new(self, type, dir).first
    end

    def rel?(dir=nil, type=nil)
      if DIRECTIONS.include?(dir.to_s)
        !self.neo_server.get_node_relationships(self, dir, type).nil? 
      else
        !self.neo_server.get_node_relationships(self, type, dir).nil? 
      end
    end

  end
end