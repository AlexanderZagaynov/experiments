require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'

Bundler.require *Rails.groups

module PracticeAWS
  class Application < Rails::Application

    Dir.glob(Rails.root.join 'lib/patches/**/*.rb').each { |file| require file }

    config.generators.assets = false
    config.generators.helper = false
    config.generators.jbuilder = false

    config.active_record.raise_in_transactional_callbacks = true

    console do
      require 'awesome_print'
      AwesomePrint.irb!
    end

  end
end
