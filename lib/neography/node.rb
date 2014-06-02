module Neography
  class Node < PropertyContainer
    include Neography::Index
    include Neography::NodeRelationship
    include Neography::NodePath
    include Neography::Equal
    include Neography::Property

    attr_accessor :neo_server

    def self.create(props = nil, db = Neography::Rest.new)
      raise ArgumentError.new("syntax deprecated") if props.is_a?(Neography::Rest)

      node = self.new(db.create_node(props))
      node.neo_server = db
      node
    end

    def self.create_unique(index, key, value, props = nil, db = Neography::Rest.new)
      raise ArgumentError.new("syntax deprecated") if props.is_a?(Neography::Rest)

      node = self.new(db.create_unique_node(index, key, value, props))
      node.neo_server = db
      node
    end

    def self.load(node, db = Neography::Rest.new)
      raise ArgumentError.new("syntax deprecated") if node.is_a?(Neography::Rest)
      node = node.first if node.kind_of?(Array)
      node = db.get_node(node) if (node.to_s.match(/^\d+$/) or node.to_s.split("/").last.match(/^\d+$/))
      if node
        node = self.new(node)
        node.neo_server = db
      end
      node
    end

    def find(*args)
      node = self.new
      node.find(args)
    end

    def del
      neo_server.delete_node!(self.neo_id)
    end

    def exist?
      begin
        neo_server.get_node(self.neo_id)
        true
      rescue NodeNotFoundException
        false
      end
    end

    ##
    # List of labels of current node.
    # Returns array of strings
    def labels
      self.neo_server.get_node_labels(self.neo_id)
    end
  end
end
