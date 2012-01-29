require 'rubygems'
require 'neography'

def create_great(name)
  Neography::Node.create("name" => name)
end

game      = create_great('The 1958 NFL Championship Game')
brando    = create_great('Marlon Brando')
alex      = create_great('Alexander the Great')
circus    = create_great('The Ringling Bros. and Barnum and Bailey')
beatles   = create_great('The Beatles')
ali       = create_great('Muhammad Ali')
bread     = create_great('Sliced Bread')
gatsby    = create_great('The Great Gatsby')

greats = [game,brando,alex,circus,beatles,ali,bread,gatsby]

def as_great(great, other_greats)
  other_greats.each do |og|
    great.outgoing(:as_great) << og
  end
end

greats.each do |g|
  ogs = greats.select{|v| v != g }.sample(1 + rand(5))
  as_great(g, ogs)
end

def the_greatest
  neo = Neography::Rest.new
  neo.execute_script("m = [:];
                      c = 0;
                      g.
                        V.
                        out.
                        groupCount(m).
                        loop(2){c++ < 1000}.iterate();
                        
                        m.sort{a,b -> b.value <=> a.value}.keySet().name[0];")
end

puts "The greatest is #{the_greatest}"