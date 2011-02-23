require 'rubygems'
require 'neography'

@neo = Neography::Rest.new

def create_node(name, mysql_id)
  @neo.create_node("name" => name, "mysql_id" => mysql_id)
end

def attended(student, school, degree, graduated)
  @neo.create_relationship("attended", student, school, {"degree" => degree, "graduated" => graduated})
end


def graduated_with_me(student)
  student = student["self"].split('/').last
  student_attended = @neo.get_node_relationships(student)[0]
  graduated = student_attended["data"]["graduated"]
  school = student_attended["end"].split('/').last
 
  @neo.traverse(school,"nodes", {"order" => "breadth first", 
                                          "uniqueness" => "node global", 
                                          "relationships" => {"type"=> "attended", "direction" => "in"}, 
                                          "return filter" => {
                                            "language" => "javascript",
                                            "body" => "position.length() == 1  
                                                       && position.endNode().getId() != #{student} 
                                                       && position.lastRelationship().getProperty(\"graduated\") == #{graduated};"}})
end

charlie = create_node("Charlie", 1)
max     = create_node("Max",     2)
peter   = create_node("Peter",   3)
carol   = create_node("Carol",   3)
tom     = create_node("Tom",     4)
jerry   = create_node("Jerry",   5)
larry   = create_node("Larry",   6)

yale    = create_node("Yale",    7)
harvard = create_node("Harvard", 8)
rutgers = create_node("Rutgers", 9)

attended(charlie,yale,"engineering", 2010)
attended(max,yale,"mathematics", 2005)
attended(peter,yale,"biology", 2010)
attended(carol,yale,"engineering", 2010)
attended(tom,harvard,"biology", 2008)
attended(jerry,rutgers,"physics", 2007)
attended(larry,rutgers,"mathematics", 2010)


puts "Charlie graduated with #{graduated_with_me(charlie).map{|n| n["data"]["name"]}.join(', ')}"

# The node levels returned are Peter, Carol
