require 'neography'
require 'benchmark'
require 'matchers'

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
  c.filter_run_excluding :slow => true, :break_gremlin => true
end


def json_content_type
  {"Content-Type"=>"application/json"}
end

def error_response(attributes)
  stub(
    code: attributes[:code],
    body: {
    message:   attributes[:message],
    exception: attributes[:exception],
    stacktrace: attributes[:stacktrace]
  }.reject { |k,v| v.nil? }.to_json
  )
end

