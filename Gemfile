source 'https://rubygems.org'

gem 'rake'
gem 'byebug'
gem "hanami-validations", "~> 2.0.alpha"
gem 'hanami',  '~> 1.3'

gem 'rom', '~> 5'
gem 'rom-sql', '~> 3'

gem 'sqlite3'
gem 'pg'

group :development do
  # Code reloading
  # See: http://hanamirb.org/guides/projects/code-reloading
  gem 'shotgun', platforms: :ruby
  gem 'hanami-webconsole'
end

group :test, :development do
  gem 'pry-byebug'
  gem 'dotenv', '~> 2.4'
end

group :test do
  gem 'rspec'
  gem 'capybara'
  gem "rom-factory", "~> 0.10"
  gem 'factory_bot', '~> 6.2'
end

group :production do
  # gem 'puma'
end
