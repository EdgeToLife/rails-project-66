# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.2'

gem 'rails', '~> 7.1.3'

gem 'sprockets-rails'

gem 'sqlite3', '~> 1.4'

gem 'puma', '>= 5.0'

gem 'jsbundling-rails'

gem 'turbo-rails'

gem 'stimulus-rails'

gem 'cssbundling-rails'

gem 'jbuilder'

gem 'tzinfo-data', platforms: %i[windows jruby]

gem 'bootsnap', require: false

gem 'sentry-rails'
gem 'sentry-ruby'

gem 'slim-rails'

gem 'omniauth'
gem 'omniauth-github'
gem 'omniauth-rails_csrf_protection'

gem 'rails-i18n'

gem 'simple_form'

gem 'octokit'

gem 'aasm'

gem 'enumerize'

gem 'dry-container'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
  gem 'faker'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'byebug'
  gem 'dotenv'
  gem 'rubocop-rails'
  gem 'slim_lint'
  gem 'web-console'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'minitest-power_assert'
  gem 'selenium-webdriver'
  gem 'webmock'
end

group :production do
  gem 'pg'
end
