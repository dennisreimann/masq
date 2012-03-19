class ActiveSupport::TestCase
  self.fixture_path = File.expand_path("../../../fixtures",  __FILE__)

  set_fixture_class :accounts => Masq::Account
  set_fixture_class :personas => Masq::Persona
  set_fixture_class :release_policies => Masq::ReleasePolicy
  set_fixture_class :sites => Masq::Site

  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include Masq::TestHelper
end