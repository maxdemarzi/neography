require 'rails'

module Neography
  class Railtie < Rails::Railtie

    # To add an initialization step from your Railtie to Rails boot process, you just need to create an initializer block:
    # See: http://api.rubyonrails.org/classes/Rails/Railtie.html
    initializer 'neography.configure' do
      # Provides a hook so people implementing the gem can do this in a railtie of their own:
      #   initializer "my_thing.neography_initialization", before: 'neography.configure' do
      #     require 'my_thing/neography'
      #   end
    end

    rake_tasks do
      load 'neography/tasks.rb'
    end
  end
end
