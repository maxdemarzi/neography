module Neography #:nodoc
  module Config #:nodoc
    extend self
    @settings = {}

    def settings
      @settings
    end

    def option(name, options = {})
      define_method(name) do
        settings.has_key?(name) ? settings[name] : options[:default]
      end
      define_method("#{name}=") { |value| settings[name] = value }
      define_method("#{name}?") { send(name) }
    end

    option :protocol, :default => 'http://'
    option :server, :default => 'localhost'
    option :port, :default => 7474
    option :directory, :default => ''
    option :log_file, :default => 'neograpy.log'
    option :log_enabled, :default => false
    option :logger, :default => defined?(Rails) ? Rails.logger : ::Logger.new($stdout)
    option :max_threads, :default => 20
    option :authentication, :default => {}
    option :username, :default => nil
    option :password, :default => nil

    def parse_config(options = {})
      options.each_pair do |name, value|
        send("#{name}=", value) if respond_to?("#{name}=")
      end
    end

    def reset
      settings.clear
    end
  end
end

