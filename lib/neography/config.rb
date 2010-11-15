module Neography

  # == Keeps configuration for neography
  #
  # The most important configuration options are <tt>Neograophy::Config[:server]</tt> and <tt>Neograophy::Config[:port]</tt> which are
  # used to locate where the neo4j database and is stored on the network.
  # If these options are not supplied then the default of localhost:9999 will be used.
  #
  # ==== Default Configurations
  # <tt>:protocol</tt>:: default <tt>http://</tt> protocol to use (can be https://)
  # <tt>:server</tt>::   default <tt>localhost</tt> where the database is stored on the network
  # <tt>:port</tt>::     default <tt>9999</tt> what port is listening
  #
  class Config
    # This code is copied from merb-core/config.rb.
    class << self
      # Returns the hash of default config values for neography
      #
      # ==== Returns
      # Hash:: The defaults for the config.
      def defaults
        @defaults ||= {
          :protocol => 'http://',
          :server => 'localhost',
          :port => '9999'
        }
      end

     
      # Yields the configuration.
      #
      # ==== Block parameters
      # c :: The configuration parameters, a hash.
      #
      # ==== Examples
      # Neography::Config.use do |config|
      #   config[:server] = '192.168.1.13'
      # end
      #
      # ==== Returns
      # nil
      def use
        @configuration ||= {}
        yield @configuration
        nil
      end
      
      
      # Set the value of a config entry.
      #
      # ==== Parameters
      # key :: The key to set the parameter for.
      # val :: The value of the parameter.
      #
      def []=(key, val)
        (@configuration ||= setup)[key] = val
      end


      # Gets the the value of a config entry
      #
      # ==== Parameters
      # key:: The key of the config entry value we want
      #
      def [](key)
        (@configuration ||= setup)[key]
      end


      # Remove the value of a config entry.
      #
      # ==== Parameters
      # key<Object>:: The key of the parameter to delete.
      #
      # ==== Returns
      # The value of the removed entry.
      #
      def delete(key)
        @configuration.delete(key)
      end


      # Remove all configuration. This can be useful for testing purpose.
      #
      #
      # ==== Returns
      # nil
      #
      def delete_all
        @configuration = nil
      end


      # Retrieve the value of a config entry, returning the provided default if the key is not present
      #
      # ==== Parameters
      # key:: The key to retrieve the parameter for.
      # default::The default value to return if the parameter is not set.
      #
      # ==== Returns
      # The value of the configuration parameter or the default.
      #
      def fetch(key, default)
        @configuration.fetch(key, default)
      end

      # Sets up the configuration
      #
      # ==== Returns
      # The configuration as a hash.
      #
      def setup()
        @configuration = {}
        @configuration.merge!(defaults)
        @configuration
      end


      # Returns the configuration as a hash.
      #
      # ==== Returns
      # The config as a hash.
      #
      def to_hash
        @configuration
      end

      # Returns the config as YAML.
      #
      # ==== Returns
      # The config as YAML.
      #
      def to_yaml
        require "yaml"
        @configuration.to_yaml
      end

      # Returns the configuration as a string.
      #
      # ==== Returns
      # The config as a string.
      #
      def to_s
        setup
        @configuration[:protocol] + @configuration[:server].to_s + ':' + @configuration[:port].to_s
      end


    end
  end

end