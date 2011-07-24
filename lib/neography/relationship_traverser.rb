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
      iterator.each do |i| 
        rel = Neography::Relationship.new(i, @node.neo_server)
        rel.start_node = Neography::Node.load(rel.start_node, @node.neo_server)
        rel.end_node = Neography::Node.load(rel.end_node, @node.neo_server)

        yield rel if match_to_other?(rel)
      end
    end

    def empty?
      first == nil
    end

    def iterator
      Array(@node.neo_server.get_node_relationships(@node, @direction, @types))
    end

    def match_to_other?(rel)
      if @to_other.nil?
        true
      elsif @direction == :outgoing
        rel.end_node == @to_other
      elsif @direction == :incoming
        rel.start_node == @to_other
      else
        rel.start_node == @to_other || rel.end_node == @to_other
      end
    end

    def to_other(to_other)
      @to_other = to_other
      self
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
      @direction = :incoming
      self
    end

    def outgoing
      @direction = :outgoing
      self
    end

  end
end