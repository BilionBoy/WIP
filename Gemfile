source 'https://rubygems.org'

# Use a versão mais recente do Rails no branch principal: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.2.2', '>= 7.2.2.1'
# O pipeline original de assets para Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'
# Use o servidor web Puma [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Use JavaScript com mapas de importação ESM [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
# Acelerador de páginas tipo SPA do Hotwire [https://turbo.hotwired.dev]
gem 'turbo-rails'
# Framework modesto de JavaScript do Hotwire [https://stimulus.hotwired.dev]
gem 'stimulus-rails'
# Construa APIs JSON com facilidade [https://github.com/rails/jbuilder]
gem 'jbuilder'
# Use o adaptador Redis para rodar o Action Cable em produção
# gem "redis", ">= 4.0.1"

# Use o Kredis para obter tipos de dados de nível superior no Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use o método has_secure_password do Active Model [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# O Windows não inclui arquivos zoneinfo, então inclua a gem tzinfo-data
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduz os tempos de inicialização por meio de cache; necessário em config/boot.rb
gem 'bootsnap', require: false

# Use variantes do Active Storage [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem 'dotenv-rails'
  # Veja https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Análise estática para vulnerabilidades de segurança [https://brakemanscanner.org/]
  gem 'brakeman', require: false
end

group :development do
  # Use o console nas páginas de exceções [https://github.com/rails/web-console]
  gem 'web-console'
end

group :test do
  # Use testes de sistema [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
end
# Use o banco de dados PostgreSQL
gem 'pg', '~> 1.1'

# Formulários
gem 'simple_form'

# Formatação ERB
gem 'htmlbeautifier'
gem 'rufo'

# Login
gem 'devise'

# Ransack
gem 'ransack'

# Paginação
gem 'pagy'

# Gerar PDF
gem 'wicked_pdf'

# Validar CPF/CNPJ
gem 'cpf_cnpj'

# Ler planilhas Excel
gem 'caxlsx'
gem 'caxlsx_rails'

# Nested Forms
gem 'cocoon'

# Identificador Unico Universal
# gem "uuid"
# Autorização de usuários
gem 'cancancan'

# Soft deleted_at
gem 'paranoia'

# Auditoria — rastreia quem criou/alterou/deletou e o quê
gem 'paper_trail'

# Imagens
gem 'image_processing', '>= 1.2'

# AXLSX
gem 'axlsx_rails'

# Jobs assíncronos — fila persistida no Postgres (sem Redis)
gem 'good_job'
