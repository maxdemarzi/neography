require 'neography'
require 'fakeweb'
require 'benchmark'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

FakeWeb.allow_net_connect = false

# To test against a real database:
# 1. Make sure empty database is running on your test neo4j server (bin/neo4j start)
# 2. Uncomment the next two lines
FakeWeb.clean_registry 
FakeWeb.allow_net_connect = true

# 3. If you want to see more, uncomment the next few lines
# require 'net-http-spy'
# Net::HTTP.http_logger_options = {:body => true}    # just the body
# Net::HTTP.http_logger_options = {:verbose => true} # see everything

def generate_text(length=8)
  chars = 'abcdefghjkmnpqrstuvwxyz'
  key = ''
  length.times { |i| key << chars[rand(chars.length)] }
  key
end