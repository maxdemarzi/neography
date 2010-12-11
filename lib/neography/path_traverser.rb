module Neography
  class PathTraverser
    include Enumerable

    attr_accessor :depth, :algorithm, :relationships, :get

    def initialize(from, to, algorithm, all=false, types = nil, dir = "all" )
      @from  = from
      @to = to
      @algorithm = algorithm
      @all = all
      @relationships = Array.new
      types.each do |type|
        @relationships << {"type" => type.to_s, "direction" => dir.to_s }
      end unless types.nil?
      @get = ["node","rel"]
      @loaded = Array.new
    end

    def nodes
      @get = ["node"]
      self
    end

    def relationships
      @get = ["rel"]
      self
    end

    alias_method :rels, :relationships

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

    def depth(d)
      d = 2147483647 if d == :all
      @depth = d
      self
    end

    def size
      [*self].size
    end

    alias_method :length, :size

    def each
      iterator.each do |path|
        paths = Array.new

        if @get.include?("node")
          path["nodes"].each_with_index do |n, i|
            @loaded[n.split('/').last.to_i] = Neography::Node.load(n) if @loaded.at(n.split('/').last.to_i).nil?
            paths[i * 2] =  @loaded[n.split('/').last.to_i]
          end
        end

        if @get.include?("rel") 
          path["relationships"].each_with_index do |r, i|
            @loaded[r.split('/').last.to_i] = Neography::Relationship.load(r) if @loaded.at(r.split('/').last.to_i).nil?
            paths[i * 2 + 1] =  @loaded[r.split('/').last.to_i] 
          end
        end
 
        yield paths.compact
      end
    end

    def empty?
      first == nil
    end

    def iterator
      if @all.nil?
        @from.neo_server.get_path(@from, @to, @relationships, @depth, @algorithm)
      else
        @from.neo_server.get_paths(@from, @to, @relationships, @depth, @algorithm)
      end
    end

  end
end