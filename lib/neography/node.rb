module Neography
  class Node < PropertyContainer
    include Neography::NodeRelationship
    include Neography::NodePath
    include Neography::Equal
    include Neography::Property

    attr_accessor :neo_server

    class << self
      def create(*args)
        # the arguments can be an hash of properties to set or a rest instance
        props = (args[0].is_a?(Hash) && args[0]) || args[1]
        db = (args[0].is_a?(Neography::Rest) && args[0]) || args[1] || Neography::Rest.new
        node = Neography::Node.new(db.create_node(props))
        node.neo_server = db
        node
      end

      def load(*args)
        # the first argument can be an hash of properties to set
        node = !args[0].is_a?(Neography::Rest) && args[0] || args[1]
        
        # a db instance can be given, it is the first argument or the second
        db = (args[0].is_a?(Neography::Rest) && args[0]) || args[1] || Neography::Rest.new
        db.get_node(node)
      end

      #alias_method :new, :create
    end

    def del
      p self.neo_id.to_i
      self.neo_server.delete_node!(self.neo_id.to_i)
    end

    def exist?
      !self.neo_server.get_node(self.neo_id).nil?
    end

  end
end
