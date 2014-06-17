guard :rspec do
  watch(%r{^lib/neography/(.+)\.rb$}) { |m| "spec/unit/#{m[1]}_spec.rb" }
  watch(%r{^lib/neography/(.+)\.rb$}) { |m| "spec/integration/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { "spec" }
end
