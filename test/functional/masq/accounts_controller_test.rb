require 'test_helper'

module Masq
  class AccountsControllerTest < ActionController::TestCase
    include Masq::Engine.routes_url_helpers

    fixtures :accounts

    def test_should_allow_signup_if_enabled
      Masq::Engine.config.masq['disable_registration'] = false
      assert_difference 'Account.count' do
        post :create, :account => valid_account_attributes
      end
      assert_redirected_to login_path
    end

    def test_should_return404_on_signup_if_disabled
      Masq::Engine.config.masq['disable_registration'] = true
      get :new
      assert_response :not_found
      post :create, :account => valid_account_attributes
      assert_response :not_found
    end

    def test_should_show_correct_message_after_signup_if_send_activation_mail_is_disabled
      Masq::Engine.config.masq['disable_registration'] = false # doesn't make sense if registration is disabled
      Masq::Engine.config.masq['send_activation_mail'] = true
      post :create, :account => valid_account_attributes
      assert_equal I18n.t(:thanks_for_signing_up_activation_link), flash[:notice]
    end

    def test_should_show_correct_message_after_signup_if_send_activation_mail_is_enabled
      Masq::Engine.config.masq['disable_registration'] = false # doesn't make sense if registration is disabled
      Masq::Engine.config.masq['send_activation_mail'] = false
      post :create, :account => valid_account_attributes
      assert_equal I18n.t(:thanks_for_signing_up), flash[:notice]
    end

    def test_should_allow_activate_if_send_activation_mail_is_enabled
      Masq::Engine.config.masq['send_activation_mail'] = true
      get :activate, :account => valid_account_attributes
      assert_response :found
    end

    def test_should_return404_activate_if_send_activation_mail_is_disabled
      Masq::Engine.config.masq['send_activation_mail'] = false
      get :activate, :account => valid_account_attributes
      assert_response :not_found
    end

    def test_should_require_login_for_edit
      get :edit
      assert_login_required
    end

    def test_should_require_login_for_update
      put :update
      assert_login_required
    end

    def test_should_require_login_for_destroy
      delete :destroy
      assert_login_required
    end

    def test_should_display_current_account_on_edit
      login_as(:standard)
      get :edit
      assert_select "input#account_email[value='quentin@example.com']"
    end

    def test_should_require_login_for_change_password_and_change_password_is_enabled
      Masq::Engine.config.masq['can_change_password'] = true
      put :change_password
      assert_login_required
    end

    def test_should_return404_on_change_password_if_change_password_is_disabled
      Masq::Engine.config.masq['can_change_password'] = false
      login_as(:standard)
      put :change_password
      assert_response :not_found
    end

    def test_should_change_password_if_change_password_is_enabled
      Masq::Engine.config.masq['can_change_password'] = true
      login_as(:standard)
      put :change_password, :old_password => 'test', :password => 'testtest', :password_confirmation => 'testtest'
      assert flash[:notice] == I18n.t(:password_has_been_changed)
    end

    def test_should_disable_account_if_confirmation_password_matches_and_can_disable_account_is_enabled
      Masq::Engine.config.masq['can_disable_account'] = true
      login_as(:standard)
      delete :destroy, :confirmation_password => 'test'
      assert !accounts(:standard).reload.enabled
      assert_redirected_to root_path
    end

    def test_should_get_404_on_disable_account_if_confirmation_password_matches_and_can_disable_account_is_disabled
      Masq::Engine.config.masq['can_disable_account'] = false
      login_as(:standard)
      delete :destroy, :confirmation_password => 'test'
      assert_response :not_found
    end

    def test_should_not_disable_account_if_confirmation_password_does_not_match
      Masq::Engine.config.masq['can_disable_account'] = true # doesn't make sense if registration is disabled
      login_as(:standard)
      delete :destroy, :confirmation_password => 'lksdajflsaf'
      assert accounts(:standard).reload.enabled
      assert_redirected_to edit_account_path
    end

    def test_should_show_change_password_if_can_can_change_password_is_enabled
      Masq::Engine.config.masq['can_change_password'] = true
      login_as(:standard)
      get :edit
      assert_select "h2:nth-of-type(2)", I18n.t(:my_password)
    end

    def test_should_not_show_change_password_if_can_change_password_is_disabled
      Masq::Engine.config.masq['can_change_password'] = false
      login_as(:standard)
      get :edit
      assert_select "h2:nth-of-type(2)", {:text => I18n.t(:my_password), :count => 0}
    end

    def test_should_show_disable_account_if_can_disable_account_is_enabled
      Masq::Engine.config.masq['can_change_password'] = true # required for h2 count in selector
      Masq::Engine.config.masq['can_disable_account'] = true
      login_as(:standard)
      get :edit
      assert_select "h2:nth-of-type(4)", I18n.t(:disable_my_account)
    end

    def test_should_not_show_disable_account_if_can_disable_account_is_disabled
      Masq::Engine.config.masq['can_change_password'] = true # required for h2 count in selector
      Masq::Engine.config.masq['can_disable_account'] = false
      login_as(:standard)
      get :edit
      assert_select "h2:nth-of-type(4)", {:text => I18n.t(:disable_my_account), :count => 0}
    end

    def test_should_set_yadis_header_on_identity_page
      account = accounts(:standard).login
      get :show, :account => account
      assert_match identity_path(account, :format => :xrds), @response.headers['X-XRDS-Location']
    end

  end
end
