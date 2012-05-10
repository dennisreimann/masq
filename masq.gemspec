$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "masq/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "masq"
  s.version     = Masq::VERSION
  s.authors     = ["Dennis Reimann"]
  s.email       = ["mail@dennisreimann.de"]
  s.homepage    = "https://github.com/dbloete/masq"
  s.summary     = "Mountable Rails engine that provides OpenID server/identity provider functionality"
  s.description = "Masq supports the current OpenID specifications (OpenID 2.0) and supports SReg, AX (fetch and store requests) and PAPE as well as some custom additions like multifactor authentication using a yubikey"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
  s.add_dependency "ruby-openid"
  s.add_dependency "ruby-yadis"
  s.add_dependency "i18n_data"

  s.add_development_dependency "minitest"
  s.add_development_dependency "turn"
  s.add_development_dependency "mocha"
end
