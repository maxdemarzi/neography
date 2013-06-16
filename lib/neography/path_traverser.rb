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
      @loaded_nodes = Array.new
      @loaded_rels = Array.new
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
            @loaded_nodes[get_id(n)] = Neography::Node.load(n) if @loaded_nodes.at(get_id(n)).nil?
            paths[i * 2] =  @loaded_nodes[get_id(n)]
          end
        end

        if @get.include?("rel") 
          path["relationships"].each_with_index do |r, i|
            @loaded_rels[get_id(r)] = Neography::Relationship.load(r)  if @loaded_rels.at(get_id(r)).nil?
            paths[i * 2 + 1] =  @loaded_rels[get_id(r)]
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
    
    private 
    def get_id(object)
      object.split('/').last.to_i
    end

  end
end