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
  end
end

DIRECTIONS = ["incoming", "in", "outgoing", "out", "all", "both"]

require 'cgi'
require 'httparty'
require 'json'
require 'oj'
require 'logger'
require 'ostruct'
require 'os'
require 'zip/zipfilesystem'

require 'neography/oj_parser'

require 'neography/config'
require 'neography/rest'
require 'neography/neography'

require 'neography/property_container'
require 'neography/property'
require 'neography/node_relationship'
require 'neography/node_path'
require 'neography/relationship_traverser'
require 'neography/node_traverser'
require 'neography/path_traverser'
require 'neography/equal'
require 'neography/index'

require 'neography/node'
require 'neography/relationship'

require 'neography/railtie' if defined? Rails::Railtie

find_and_require_user_defined_code

