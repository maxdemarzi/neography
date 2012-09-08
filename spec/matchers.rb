# Convenience matcher for matching JSON fields with a hash
RSpec::Matchers.define :json_match do |field, expected|

  match do |actual|
    expected == JSON.parse(actual[field])
  end

  failure_message_for_should do
    "expected JSON in field '#{@field}' to not match '#{@expected}'"
  end

  description do
    "JSON in field '#{field}' should match '#{expected.inspect}'"
  end

end
