namespace :masq do

  namespace :install do
    desc "Install configuration and migrations"
    task :all do
      %w(config migrations).each { |t| Rake::Task["masq:install:#{t}"].invoke }
    end

    desc "Copy configuration file from masq to application"
    task :config do
      target = Rails.root.join("config/masq.yml")
      unless File.exists?(target)
        require 'fileutils'
        source = File.expand_path('../../../config/masq.example.yml', __FILE__)
        FileUtils.cp source, target
        puts "Created config/masq.yml"
      end
    end
  end

  namespace :openid do
    desc 'Cleanup OpenID store'
    task :cleanup_store => :environment do
      Masq::ActiveRecordStore.new.cleanup
    end
  end

  namespace :test do
    desc "Prepare CI build task"
    task :prepare_ci do
      adapter  = ENV["DB_ADAPTER"] || "sqlite3"
      database = ENV["DB_DATABASE"] || ("sqlite3" == adapter ? "db/test.sqlite3" : "masq_test")

      config = {
        "test" => {
          "adapter" => adapter,
          "database" => database,
          "username" => ENV["DB_USERNAME"],
          "password" => ENV["DB_PASSWORD"],
          "port" => ENV["DB_PORT"] ? ENV["DB_PORT"].to_i : nil,
          "socket" => ENV["DB_SOCKET"] ? ENV["DB_SOCKET"] : nil,
          "host" => "localhost",
          "encoding" => "utf8",
          "pool" => 5,
          "timeout" => 5000
        }
      }

      File.open(Rails.root.join("config/database.yml"), "w") do |f|
        f.write(config.to_yaml)
      end
    end

    desc "Run CI build task"
    task :ci => [:prepare_ci] do
      Rake::Task['test'].invoke
    end
  end

end