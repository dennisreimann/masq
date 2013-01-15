module Masq
  class AccountsController < BaseController
    before_filter :check_disabled_registration, :only => [:new, :create]
    before_filter :login_required, :except => [:show, :new, :create, :activate, :resend_activation_email]
    before_filter :detect_xrds, :only => :show

    def show
      @account = Account.where(:login => params[:account], :enabled => true).first
      raise ActiveRecord::RecordNotFound if @account.nil?

      respond_to do |format|
        format.html do
          response.headers['X-XRDS-Location'] = identity_url(:account => @account, :format => :xrds, :protocol => scheme)
        end
        format.xrds
      end
    end

    def new
      @account = Account.new
    end

    def create
      cookies.delete :auth_token
      account_params[:login] = account_params[:email] if email_as_login?
      signup = Signup.create_account!(account_params)
      if signup.succeeded?
        redirect_to login_path, :notice => signup.send_activation_email? ?
          t(:thanks_for_signing_up_activation_link) :
          t(:thanks_for_signing_up)
      else
        @account = signup.account
        render :action => 'new'
      end
    end

    def update
      account_params.delete(:email) if email_as_login?
      account_params.delete(:login)

      if current_account.update_attributes(account_params)
        redirect_to edit_account_path(:account => current_account), :notice => t(:profile_updated)
      else
        render :action => 'edit'
      end
    end

    def destroy
      return render_404 unless Masq::Engine.config.masq['can_disable_account']

      if current_account.authenticated?(params[:confirmation_password])
        current_account.disable!
        current_account.forget_me
        cookies.delete :auth_token
        reset_session
        redirect_to root_path, :notice => t(:account_disabled)
      else
        redirect_to edit_account_path, :alert => t(:entered_password_is_wrong)
      end
    end

    def activate
      return render_404 unless Masq::Engine.config.masq['send_activation_mail']

      begin
        account = Account.find_and_activate!(params[:activation_code])
        redirect_to login_path, :notice => t(:account_activated_login_now)
      rescue ArgumentError, Account::ActivationCodeNotFound
        redirect_to new_account_path, :alert => t(:couldnt_find_account_with_code_create_new_one)
      rescue Account::AlreadyActivated
        redirect_to login_path, :alert => t(:account_already_activated_please_login)
      end
    end

    def change_password
      return render_404 unless Masq::Engine.config.masq['can_change_password']

      if Account.authenticate(current_account.login, params[:old_password])
        if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
          current_account.password_confirmation = params[:password_confirmation]
          current_account.password = params[:password]
          if current_account.save
            redirect_to edit_account_path(:account => current_account), :notice => t(:password_has_been_changed)
          else
            redirect_to edit_account_path, :alert => t(:sorry_password_couldnt_be_changed)
          end
        else
          @old_password = params[:old_password]
          redirect_to edit_account_path, :alert => t(:confirmation_of_new_password_invalid)
        end
      else
        redirect_to edit_account_path, :alert => t(:old_password_incorrect)
      end
    end

    def resend_activation_email
      account = Account.find_by_login(params[:account])

      if account && !account.active?
        AccountMailer.signup_notification(account).deliver
        flash[:notice] = t(:activation_link_resent)
      else
        flash[:alert] = t(:account_already_activated_or_missing)
      end

      redirect_to login_path
    end

    protected

    def check_disabled_registration
      render_404 if Masq::Engine.config.masq['disable_registration']
    end

    def detect_xrds
      if params[:account] =~ /\A(.+)\.xrds\z/
        request.format = :xrds
        params[:account] = $1
      end
    end

    def account_params
      @account_params ||= params.require(:account).permit(:login, :email, :password, :password_confirmation, :public_persona_id, :yubikey_mandatory)
    end

  end
end
