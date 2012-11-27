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

module Neography

  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Config.new
  end

end
