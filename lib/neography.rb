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
require 'multi_json'
require 'logger'
require 'ostruct'
require 'os'
require 'zip/zipfilesystem'

require 'neography/multi_json_parser'

require 'neography/version'

require 'neography/config'

require 'neography/rest/helpers'
require 'neography/rest/paths'

require 'neography/rest/properties'
require 'neography/rest/indexes'
require 'neography/rest/auto_indexes'

require 'neography/rest/nodes'
require 'neography/rest/node_properties'
require 'neography/rest/node_relationships'
require 'neography/rest/node_indexes'
require 'neography/rest/node_auto_indexes'
require 'neography/rest/node_traversal'
require 'neography/rest/node_paths'
require 'neography/rest/relationships'
require 'neography/rest/relationship_properties'
require 'neography/rest/relationship_indexes'
require 'neography/rest/relationship_auto_indexes'
require 'neography/rest/cypher'
require 'neography/rest/gremlin'
require 'neography/rest/batch'
require 'neography/rest/clean'
require 'neography/connection'
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

