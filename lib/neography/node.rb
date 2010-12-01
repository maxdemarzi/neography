module Neography
  class Node < PropertyContainer

    class << self
      def create(*args)
        # the arguments can be an hash of properties to set or a rest instance
        props = (args[0].respond_to?(:each_pair) && args[0]) || args[1]
        db = (args[0].is_a?(Neography::Rest) && args[0]) || args[1] || Neography::Rest.new
        Neography::Node.new(db.create_node(props))
      end

      def load(*args)
        # the first argument can be an hash of properties to set
        node = !args[0].is_a?(Neography::Rest) && args[0] || args[1]

        # a db instance can be given, it is the first argument or the second
        db = (args[0].is_a?(Neography::Rest) && args[0]) || args[1] || Neography::Rest.new
        node = db.get_node(node)
        node = Neography::Node.new(node) unless node.nil?
        node
      end

      #alias_method :new, :create
    end

  end
end