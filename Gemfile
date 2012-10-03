source "http://rubygems.org"

# Specify your gem's dependencies in simpex.gemspec
gemspec

group :test do
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-minitest'
  gem 'mocha'
  gem 'growl'
end

