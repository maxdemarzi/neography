module Neography
  module Index

    def self.included(base)
      base.extend(ClassMethods)
    end
  
    def add_to_index(index, key, value, unique = false)
      if self.is_a? Neography::Node
        self.neo_server.add_node_to_index(index, key, value, self.neo_id, unique)
      else
        self.neo_server.add_relationship_to_index(index, key, value, self.neo_id)
      end
    end

    def remove_from_index(*args)
      if self.is_a? Neography::Node
        self.neo_server.remove_node_from_index(*args)
      else
        self.neo_server.remove_relationship_from_index(*args)
      end
    end

    module ClassMethods
      def find(*args)
        db = args[3] ? args.pop : Neography::Rest.new

        if self <= Neography::Node
          nodes = []
          results = db.find_node_index(*args)
          return nil unless results
          results.each do |r|
            node = self.new(r)
            node.neo_server = db
            nodes << node
          end
          nodes.size > 1 ? nodes : nodes.first
        else
          rels = []
          results = db.find_relationship_index(*args)
          return nil unless results
          results.each do |r|
            rel = self.load(r, db)
            rels << rel
          end
          rels.size > 1 ? rels : rels.first
        end  
      end
    end
    
  end
end
