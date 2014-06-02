# Convenience matcher for matching JSON fields with a hash
RSpec::Matchers.define :json_match do |field, expected|

  match do |actual|
    expected == JSON.parse(actual[field])
  end

  failure_message do
    "expected JSON in field '#{field}' to match '#{expected}'"
  end

  description do
    "JSON in field '#{field}' should match '#{expected.inspect}'"
  end

end

# Convenience matcher for matching fields in a hash
RSpec::Matchers.define :hash_match do |field, expected|

  match do |actual|
    expected == actual[field]
  end

  failure_message do
    "expected field '#{field}' to match '#{expected}'"
  end

  description do
    "field '#{field}' should match '#{expected.inspect}'"
  end

end
