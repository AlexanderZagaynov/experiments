source 'https://rubygems.org'
ruby File.read('.ruby-version').gsub(/[[:space:]]+/, '')

gem 'rails', '~> 4.2.5'

# Database adapters
gem 'sqlite3'

# DSLs
gem 'slim-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'jbuilder'

# Vendor assets and frameworks
gem 'bootstrap-sass'
gem 'jquery-rails'

# Asset related tools
gem 'uglifier'
gem 'therubyracer', platforms: :ruby

# Deployment tools
gem 'capistrano-rails', group: :development

group :production do
  gem 'unicorn'
end

group :development do
  gem 'spring'
  gem 'web-console'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'quiet_assets'
end
