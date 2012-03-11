Masq::Engine.configure do
  config.masq = YAML.load(File.read("#{Rails.root}/config/masq.yml"))[Rails.env]
end
