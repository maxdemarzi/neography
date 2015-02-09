module Neography
  class Relationship < PropertyContainer
    include Neography::Equal
    include Neography::Property
    include Neography::Index
    
    attr_accessor :start_node, :end_node, :rel_type

    class << self

      def create(type, from_node, to_node, props = nil)
        rel = Neography::Relationship.new(from_node.neo_server.create_relationship(type, from_node, to_node, props))
        rel.start_node = from_node
        rel.end_node = to_node
        rel.rel_type = type
        rel
      end

      def create_unique(index, key, value, type, from_node, to_node, props = nil)
        rel = Neography::Relationship.new(from_node.neo_server.create_unique_relationship(index, key, value, type, from_node, to_node, props))
        rel.start_node = from_node
        rel.end_node = to_node
        rel.rel_type = type
        rel
      end

      def load(rel, db = Neography::Rest.new)
        raise ArgumentError.new("syntax deprecated") if rel.is_a?(Neography::Rest)

        rel = db.get_relationship(rel)
        if rel
          rel = Neography::Relationship.new(rel, db)
          rel.start_node = Neography::Node.load(rel.start_node, db)
          rel.end_node = Neography::Node.load(rel.end_node, db)
        end
        rel
      end
    end

    def initialize(hash=nil, server=nil)
      super(hash)
      @start_node = hash["start"].split('/').last
      @end_node = hash["end"].split('/').last
      @rel_type = hash["type"]
      self.neo_server = server
    end

    def neo_server
      @neo_server ||= self.start_node.neo_server
    end

    def neo_server=(server)
      @neo_server = server
    end

    def del
      neo_server.delete_relationship(neo_id)
    end

    def exist?
      begin
        start_node.neo_server.get_relationship(neo_id)
        true
      rescue Neography::RelationshipNotFoundException
        false
      end
    end

    def other_node(node)
      if node == @start_node
        @end_node
      else
        @start_node
      end
    end

  end
end
