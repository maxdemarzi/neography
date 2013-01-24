module Neography
  class NodeTraverser
    include Enumerable

    attr_accessor :order, :uniqueness, :depth, :prune, :filter, :relationships

    def initialize(from, types = nil, dir = "all" )
      @from  = from
      @order = "depth first"
      @uniqueness = "none"
      @relationships = Array.new
      types.each do |type|
        @relationships << {"type" => type.to_s, "direction" => dir.to_s }
      end unless types.nil?
    end

    def <<(other_node)
      create(other_node)
      self
    end

    def create(other_node)
      case @relationships.first["direction"]
        when "outgoing", "out"
          rel = Neography::Relationship.new(@from.neo_server.create_relationship(@relationships.first["type"], @from, other_node))
        when "incoming", "in"
          rel = Neography::Relationship.new(@from.neo_server.create_relationship(@relationships.first["type"], other_node, @from))
        else
          rel = Array.new
          rel << Neography::Relationship.new(@from.neo_server.create_relationship(@relationships.first["type"], @from, other_node))
          rel << Neography::Relationship.new(@from.neo_server.create_relationship(@relationships.first["type"], other_node, @from))
      end
      rel       
    end

    def both(type)
      @relationships << {"type" => type.to_s, "direction" => "all"}
      self
    end

    def outgoing(type)
      @relationships << {"type" => type.to_s, "direction" => "out"}
      self
    end

    def incoming(type)
      @relationships << {"type" => type.to_s, "direction" => "in"}
      self
    end

    def uniqueness(u)
      @uniqueness = u
      self
    end

    def order(o)
      @order = o
      self
    end

    def filter(body)
      @filter = {
        "language" => "javascript",
        "body"     => body
      }
      self
    end

    def prune(body)
      @prune = {
        "language" => "javascript",
        "body"     => body
      }
      self
    end

    def depth(d)
      d = 2147483647 if d == :all
      @depth = d
      self
    end

    def include_start_node
      @filter = {
        "language" => "builtin",
        "name"     => "all"
      }
      self
    end

    def size
      [*self].size
    end

    alias_method :length, :size

    def [](index)
      each_with_index {|node,i| break node if index == i}
    end

    def empty?
      first == nil
    end

    def each
      iterator.each do |i| 
        node = @from.class.new(i)
        node.neo_server = @from.neo_server
        yield node
      end
    end

    def iterator
      options = {
        "order"         => @order,
        "uniqueness"    => @uniqueness,
        "relationships" => @relationships
      }
      options["prune evaluator"] = @prune  unless @prune.nil?
      options["return filter"]   = @filter unless @filter.nil?
      options["depth"]           = @depth  unless @depth.nil?

      if @relationships[0]["type"].empty?
        rels = @from.neo_server.get_node_relationships(@from, @relationships[0]["direction"]) || []
        case @relationships[0]["direction"]
          when "in"
            rels.collect { |r| @from.neo_server.get_node(r["start"]) } #.uniq
          when "out"
            rels.collect { |r| @from.neo_server.get_node(r["end"]) } #.uniq
          else
            rels.collect { |r|
            if @from.neo_id == r["start"].split('/').last
              @from.neo_server.get_node(r["end"])
            else
              @from.neo_server.get_node(r["start"])
            end
            } #.uniq
        end
      else
        @from.neo_server.traverse(@from, "nodes", options)
      end
    end

  end

end
