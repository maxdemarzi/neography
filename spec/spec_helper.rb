require 'neography'
require 'fakeweb'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

FakeWeb.allow_net_connect = false

#To test against a real database:
#1. Make sure empty database is running (./bin/neo4j-rest start)
#2. Uncomment the next two lines
FakeWeb.clean_registry 
FakeWeb.allow_net_connect = true

def generate_text(length=8)
  chars = 'abcdefghjkmnpqrstuvwxyz'
  key = ''
  length.times { |i| key << chars[rand(chars.length)] }
  key
end