module Neography
  class Node < PropertyContainer
    extend  Neography::Index
    include Neography::NodeRelationship
    include Neography::NodePath
    include Neography::Equal
    include Neography::Property

    attr_accessor :neo_server

    class << self
      def create(*args)
        # the arguments can be an hash of properties to set or a rest instance
        props = (args[0].respond_to?(:each_pair) && args[0]) || args[1]
        db = (args[0].is_a?(Neography::Rest) && args[0]) || args[1] || Neography::Rest.new
        node = self.class.new(db.create_node(props))
        node.neo_server = db
        node
      end

      def load(*args)
        # the first argument can be an hash of properties to set
        node = !args[0].is_a?(Neography::Rest) && args[0] || args[1]

        # a db instance can be given, it is the first argument or the second
        db = (args[0].is_a?(Neography::Rest) && args[0]) || args[1] || Neography::Rest.new
        node = db.get_node(node)
        node = self.class.new(node) unless node.nil?
        node.neo_server = db unless node.nil?
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