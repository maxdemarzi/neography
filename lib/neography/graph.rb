module Neography
  module Graph
    def self.included(base)
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def save
        if self.class.instance_methods.include? :save
          super
        end
        graph
      end

      def graph
        (1..5000).to_a.each do |i|
          p i
          begin
            node = Neography::Node.load(i)
            p node
            unless node.nil?
              node.del
            end
          end
        end
        @node ||= Neography::Node.load(self.id)
        @node ||= Neography::Node.create({ "id" => self.id, "type" => self.class.to_s })
        @node
      end
    end#InstanceMethods
  end
end
