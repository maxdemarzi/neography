require "singleton"
require "rails"

module Rails #:nodoc:
  module Neography #:nodoc:
    class Railtie < Rails::Railtie #:nodoc:    
      config.neography ::Neography::Config

      initializer "setup database" do
        config_file = Rails.root.join("config", "neography.yml")
        if config_file.file?
          settings = YAML.load(ERB.new(config_file.read).result)[Rails.env]
          ::Neography.parse_config(settings) if settings.present?
        end
      end

      # After initialization we will warn the user if we can't find a mongoid.yml and
      # alert to create one.
      initializer "warn when configuration is missing" do
        config.after_initialize do
          unless Rails.root.join("config", "neography.yml").file?
            puts "\nConfig not found. Create a config file at: config/neography.yml"
          end
        end
      end

    end
  end
end
