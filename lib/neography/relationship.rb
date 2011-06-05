module Neography
  class Relationship < PropertyContainer
    include Neography::Equal
    include Neography::Property

    attr_accessor :start_node, :end_node, :rel_type

    class << self

      def create(type, from_node, to_node, props=nil)
        rel = Neography::Relationship.new(from_node.neo_server.create_relationship(type, from_node, to_node, props))
        rel.start_node = from_node
        rel.end_node = to_node
        rel.rel_type = type
        rel
      end

      def load(*args)
        # the first argument can be an hash of properties to set
        rel = !args[0].is_a?(Neography::Rest) && args[0] || args[1]

        # a db instance can be given, it is the first argument or the second
        db = (args[0].is_a?(Neography::Rest) && args[0]) || args[1] || Neography::Rest.new
        rel = db.get_relationship(rel)
        unless rel.nil?
          rel = Neography::Relationship.new(rel) 
          rel.start_node = Neography::Node.load(rel.start_node) 
          rel.end_node = Neography::Node.load(rel.end_node) 
        end
        rel
      end
    end

    def initialize(hash=nil, server=nil)
      super(hash)
      @start_node = hash["start"].split('/').last
      @end_node = hash["end"].split('/').last
      @rel_type = hash["type"]
      neo_server = server
    end
    
    def neo_server
      @neo_server ||= self.start_node.neo_server
    end
    
    def neo_server=(server)
      @neo_server = server
    end

    def del
      self.start_node.neo_server.delete_relationship(self.neo_id)
    end

    def exist?
      !self.start_node.neo_server.get_relationship(self.neo_id).nil?
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