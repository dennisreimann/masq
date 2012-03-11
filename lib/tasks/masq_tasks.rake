namespace :masq do
  namespace :openid do
    desc 'Cleanup OpenID store'
    task :cleanup_store => :environment do
      Masq::ActiveRecordStore.new.cleanup
    end
  end
end