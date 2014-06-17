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

    def labels
      @cached_labels ||= [self.neo_server.get_node_labels(self.neo_id)].compact.flatten
    end

    def set_labels(labels)
      # I just invalidate the cache instead of updating it to make sure
      # it doesn't contain something else than what ends up in neo4j
      # (consider duplicate/invalid labels, etc).
      @cached_labels = nil
      self.neo_server.set_label(self, [labels].flatten)
    end
    alias_method :set_label, :set_labels

    def add_labels(labels)
      # Just invalidating the cache on purpose, see set_labels
      @cached_labels = nil
      self.neo_server.add_label(self, [labels].flatten)
    end
    alias_method :add_label, :add_labels


    def delete_label(label)
      @cached_labels = nil
      self.neo_server.delete_label(self, label)
    end

    def cached_labels=(labels)
      @cached_labels = [labels].flatten
    end
  end
end
