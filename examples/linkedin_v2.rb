require 'rubygems'
require 'neography'

@neo = Neography::Rest.new

johnathan = Neography::Node.create("name" =>'Johnathan')
mark      = Neography::Node.create("name" =>'Mark')
phill     = Neography::Node.create("name" =>'Phill')
mary      = Neography::Node.create("name" =>'Mary')

johnathan.both(:friends) << mark
mark.both(:friends) << phill
phill.both(:friends) << mary
mark.both(:friends) << mary

johnathan.all_simple_paths_to(mary).incoming(:friends).depth(4).nodes.each do |node|
  puts node.map{|n| n.name }.join(' => friends => ')
end

# RESULT
# Johnathan => friends => Mark => friends => Phill => friends => Mary
# Johnathan => friends => Mark => friends => Mary