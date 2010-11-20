def find_and_require_user_defined_code
  extensions_path = ENV['neography_extensions'] || "~/.neography"
  extensions_path = File.expand_path(extensions_path)
  if File.exists?(extensions_path)
    Dir.open extensions_path do |dir|
      dir.entries.each do |file|
        if file.split('.').size > 1 && file.split('.').last == 'rb'
          extension = File.join(File.expand_path(extensions_path), file) 
          require(extension) && puts("Loaded Extension: #{extension}")
        end
      end
    end
  else
    puts "No Extensions Found: #{extensions_path}"
  end
end


require 'httparty'
require 'json'
require 'logger'

require 'neography/rest'

find_and_require_user_defined_code

