require 'rubygems'
require 'neography'

@neo = Neography::Rest.new

def suggestions_for(node)
  node.incoming(:friends).order("breadth first").uniqueness("node global").filter("position.length() == 2;").depth(2)
end

johnathan = Neography::Node.create("name" =>'Johnathan')
mark      = Neography::Node.create("name" =>'Mark')
phill     = Neography::Node.create("name" =>'Phill')
mary      = Neography::Node.create("name" =>'Mary')
luke      = Neography::Node.create("name" =>'Luke')

johnathan.both(:friends) << mark
mark.both(:friends) << mary
mark.both(:friends) << phill
phill.both(:friends) << mary
phill.both(:friends) << luke

puts "Johnathan should become friends with #{suggestions_for(johnathan).map{|n| n.name }.join(', ')}"

# RESULT
# Johnathan should become friends with Mary, Phill