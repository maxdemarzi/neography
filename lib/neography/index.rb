module Neography
  module Index

    def self.included(base)
      base.extend(ClassMethods)
    end
  
    def add_to_index(index, key, value)
      if self.is_a? Neography::Node
        neo_server.add_node_to_index(index, key, value, self.neo_id)
      else
        neo_server.add_relationship_to_index(index, key, value, self.neo_id)
      end
    end

    def remove_from_index(*args)
      if self.is_a? Neography::Node
        neo_server.remove_node_from_index(*args)
      else
        neo_server.remove_relationship_from_index(*args)
      end
    end

    module ClassMethods
      def find(*args)
        if name == "Neography::Node"
          if args.size > 1
            neo_server.find_node_index(*args)
          else
            neo_server.get_node_index(*args)
          end
        else
          if args.size > 1
            neo_server.find_relationship_index(*args)
          else
            neo_server.get_relationship_index(*args)
          end
        end  
      end
    end
    
  end
end