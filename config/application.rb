require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MenuxT
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])
    config.paths['lib/templates/erb/scaffold'] = 'lib/templates/erb/scaffold'

    config.time_zone = 'La Paz' # Configuração do Time Zone

    config.i18n.default_locale = :'pt-BR' # Configuração do idioma padrão

    # Fila assíncrona via Good Job (Postgres, sem Redis)
    # Modo :async — roda dentro do processo Puma, sem worker separado
    config.active_job.queue_adapter = :good_job
    config.good_job.execution_mode  = :async

    # Redireciona todos os erros HTTP para o ErrorsController
    config.exceptions_app = self.routes

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
