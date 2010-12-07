module Neography
  class NodeTraverser
    include Enumerable

    attr_accessor :order, :uniqueness, :depth, :prune, :filter

    def initialize(from, types = nil, dir=nil)
      @from  = from
      @depth = 1
      @order = "depth first"
      @uniqueness = "none"
      if types.nil? || dir.nil?
#        @td    = org.neo4j.kernel.impl.traversal.TraversalDescriptionImpl.new.breadth_first()
      else
#        @types  = type_to_java(type)
#        @dir   = dir_to_java(dir)
#        @td    = org.neo4j.kernel.impl.traversal.TraversalDescriptionImpl.new.breadth_first().relationships(@type, @dir)
      end
    end

  end

end