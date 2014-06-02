# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec do
  # Just rerun the whole suite until the file names are matching
  # in lib/ and spec/
  #
  # watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  # watch(%r{^lib/(.+)\.rb$})     { |m| "spec/unit/lib/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb$})     { "spec" }

  watch(%r{^spec/.+_spec\.rb$})
  watch('spec/spec_helper.rb')  { "spec" }
end
