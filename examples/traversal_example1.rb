require 'rubygems'
require 'neography'

@neo = Neography::Rest.new

def create_node(level, type)
  @neo.create_node("NODE_LEVEL" => level, "TYPE" => type)
end

def create_other_node(type)
  @neo.create_node("TYPE" => type)
end


def get_nodes_by_level(level, node)
  starting_id = node["self"].split('/').last

  @neo.traverse(node,"nodes", {"order" => "breadth first", 
                                          "uniqueness" => "node global", 
                                          "relationships" => {"type"=> "linked", "direction" => "out"}, 
                                          "prune evaluator" => {
                                            "language" => "javascript",
                                            "body" => "position.startNode().hasProperty('NODE_LEVEL') 
                                                    && position.startNode().getProperty('NODE_LEVEL')==5 
                                                    && position.startNode().getId()!=#{starting_id};"},
                                         "return filter" => {
                                            "language" => "javascript",
                                            "body" => "position.endNode().hasProperty('NODE_LEVEL') && position.endNode().getProperty('NODE_LEVEL')==5;"}})
end

node1 = create_node(5, "N")
node2 = create_node(5, "N")
node3 = create_node(5, "N")
node4 = create_node(5, "N")
node5 = create_node(5, "N")
node6 = create_node(5, "N")
node7 = create_node(5, "N")

node8 = create_other_node("Y")
node9 = create_other_node("Y")
node10 = create_other_node("Y")

node11 = create_node(6, "N")
node12 = create_node(7, "N")
node13 = create_node(8, "N")


@neo.create_relationship("linked", node1, node2)
@neo.create_relationship("linked", node2, node3)
@neo.create_relationship("linked", node3, node4)
@neo.create_relationship("linked", node4, node5)
@neo.create_relationship("linked", node5, node6)
@neo.create_relationship("linked", node6, node7)

@neo.create_relationship("linked", node2, node8)
@neo.create_relationship("linked", node3, node9)
@neo.create_relationship("linked", node4, node10)

@neo.create_relationship("linked", node5, node11)
@neo.create_relationship("linked", node6, node12)
@neo.create_relationship("linked", node7, node13)

puts "The node levels returned are  #{get_nodes_by_level(5, node1).map{|n| n["data"]["NODE_LEVEL"]}.join(', ')}"

# The node levels returned are  5, 5, 5, 5, 5, 5, 5
