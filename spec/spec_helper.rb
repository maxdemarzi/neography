require 'neography'
require 'benchmark'
require 'matchers'
require 'coveralls'
Coveralls.wear!

# If you want to see more, uncomment the next few lines
# require 'net-http-spy'
# Net::HTTP.http_logger_options = {:body => true}    # just the body
# Net::HTTP.http_logger_options = {:verbose => true} # see everything

def generate_text(length=8)
  chars = 'abcdefghjkmnpqrstuvwxyz'
  key = ''
  length.times { |i| key << chars[rand(chars.length)] }
  key
end

RSpec.configure do |c|
  c.filter_run_excluding :slow => true, :gremlin => true, :reference => true
end


def json_content_type
  {"Content-Type"=>"application/json"}
end

def error_response(attributes)
  request_uri = double()
  request_uri.stub(:request_uri).and_return("")
  
  http_header = double()
  http_header.stub(:request_uri).and_return(request_uri)
  
  double(
    http_header: http_header,
    code: attributes[:code],
    body: {
    message:   attributes[:message],
    exception: attributes[:exception],
    stacktrace: attributes[:stacktrace]
  }.reject { |k,v| v.nil? }.to_json
  )
end

