module Neography
  class Node < PropertyContainer
    include Neography::Index
    include Neography::NodeRelationship
    include Neography::NodePath
    include Neography::Equal
    include Neography::Property

    attr_accessor :neo_server

    class << self
      def create(props = nil, db = Neography::Rest.new)
        raise ArgumentError.new("syntax deprecated") if props.is_a?(Neography::Rest)

        node = self.new(db.create_node(props))
        node.neo_server = db
        node
      end

      def load(node, db = Neography::Rest.new)
        raise ArgumentError.new("syntax deprecated") if node.is_a?(Neography::Rest)

        node = db.get_node(node)
        if node
          node = self.new(node)
          node.neo_server = db
        end
        node
      end

      #alias_method :new, :create
    end

    def del
      self.neo_server.delete_node!(self.neo_id)
    end

    def exist?
      !self.neo_server.get_node(self.neo_id).nil?
    end

  end
end
