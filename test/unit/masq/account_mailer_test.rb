require 'test_helper'

module Masq
  class AccountMailerTest < ActiveSupport::TestCase

    def test_should_send_signup_notification_if_send_notification_mail_option_is_enabled
      Masq::Engine.config.masq['send_activation_mail'] = true
      account = Account.new valid_account_attributes
      account.activation_code = 'openid123'
      response = AccountMailer.signup_notification(account)
      assert_equal account.email, response.to[0]
      response.parts.each { |part| assert part.body.match('openid123') }
    end

    def test_should_not_send_signup_notification_if_send_notification_mail_option_is_disabled
      Masq::Engine.config.masq['send_activation_mail'] = false
      account = Account.new valid_account_attributes
      assert_raise RuntimeError, "send_activation_mail deactivated" do
        AccountMailer.signup_notification(account)
      end
    end

    def test_should_send_forgot_password
      account = Account.new valid_account_attributes
      account.password_reset_code = 'openid123'
      response = AccountMailer.forgot_password(account)
      assert_equal account.email, response.to[0]
      response.parts.each { |part| assert part.body.match('openid123') }
    end

  end
end
