source "http://rubygems.org"

group :development, :test do
  platforms :ruby, :mswin, :mingw do
    case ENV['DB_ADAPTER']
    when 'mysql2'
      gem 'mysql2'
    when 'postgresql'
      gem 'pg'
    else
      gem 'sqlite3'
    end
  end
  gem 'minitest'
  gem 'turn'
  gem 'mocha'
  gem 'ruby_gntp'
  gem 'guard-minitest'
  gem 'rb-fsevent', :require => false
end

gemspec
