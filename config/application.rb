require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Weby
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.autoload_paths += Dir["#{config.root}/lib/weby/components/**/*"]
    config.autoload_paths += Dir["#{config.root}/vendor/engines/*/lib/weby/components/**/*"]

    # Activate observers that should always be running.
    config.active_record.observers = :page_position_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Brasilia'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir["#{config.root}/**/locales/**/*.yml"]
    config.i18n.default_locale = 'pt-BR'

    # Clean generators
    config.generators do |g|
      g.helper false
      g.stylesheets false
      g.javascripts false
      g.test_framework :rspec,
                       fixtures: false,
                       view_specs: false,
                       helper_specs: false,
                       routing_specs: false,
                       controller_specs: false,
                       request_specs: false
    end

    # Set layout in devise controllers
    config.to_prepare do
      Devise::RegistrationsController.layout 'weby_sessions'
      Devise::PasswordsController.layout 'weby_sessions'
      Devise::ConfirmationsController.layout 'weby_sessions'
      Devise::UnlocksController.layout 'weby_sessions'
    end
  end
end
