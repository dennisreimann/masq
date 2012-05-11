module Masq
  class AccountMailer < ActionMailer::Base
    default :from => Masq::Engine.config.masq['email']
    default_url_options[:host] = Masq::Engine.config.masq['host']

    def signup_notification(account)
      raise "send_activation_mail deactivated" unless Masq::Engine.config.masq['send_activation_mail']
      @account = account
      mail :to => account.email, :subject => I18n.t(:please_activate_your_account)
    end

    def forgot_password(account)
      @account = account
      mail :to => account.email, :subject => I18n.t(:your_request_for_a_new_password)
    end
  end
end
