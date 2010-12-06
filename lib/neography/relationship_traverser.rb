module Neography
  class RelationshipTraverser
    include Enumerable

    def initialize(node, types, direction)
      @node      = node
      @types     = [types]
      @direction = direction
    end

    def to_s
      if @types.size == 1 && !@types.empty?
        "#{self.class} [type: #{@type} dir:#{@direction}]"
      elsif !@types.empty?
        "#{self.class} [types: #{@types.join(',')} dir:#{@direction}]"
      else
        "#{self.class} [types: ANY dir:#{@direction}]"
      end
    end

    def each
      iterator.each { |i| yield Neography::Relationship.new(i, @node.neo_server) }
    end

    def empty?
      first == nil
    end
    
    def iterator
      @node.neo_server.get_node_relationships(@node, @direction, @types)
    end

    def del
      each { |rel| @node.neo_server.delete_relationship(rel) }
    end

    def size
      [*self].size
    end

    def both
      @direction = :both
      self
    end

    def incoming
      raise "Not allowed calling incoming when finding several relationships types" if @types
      @direction = :incoming
      self
    end

    def outgoing
      raise "Not allowed calling outgoing when finding several relationships types" if @types
      @direction = :outgoing
      self
    end

  end
end