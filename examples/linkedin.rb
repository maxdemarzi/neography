require 'rubygems'
require 'neography'

@neo = Neography::Rest.new

def create_person(name)
  @neo.create_node("name" => name)
end

def make_mutual_friends(node1, node2)
  @neo.create_relationship("friends", node1, node2)
  @neo.create_relationship("friends", node2, node1)
end

def degrees_of_separation(start_node, destination_node)
  paths =  @neo.get_paths(start_node, destination_node, {"type"=> "friends", "direction" => "in"}, depth=4, algorithm="allSimplePaths")
  paths.each do |p|
   p["names"] = p["nodes"].collect {|node| @neo.get_node_properties(node, "name")["name"] }
  end

end

johnathan = create_person('Johnathan')
mark      = create_person('Mark')
phill     = create_person('Phill')
mary      = create_person('Mary')

make_mutual_friends(johnathan, mark)
make_mutual_friends(mark, phill)
make_mutual_friends(phill, mary)
make_mutual_friends(mark, mary)

degrees_of_separation(johnathan, mary).each do |path|
  puts path["names"].join(' => friends => ') 
end

# RESULT
# Johnathan => friends => Mark => friends => Phill => friends => Mary
# Johnathan => friends => Mark => friends => Mary