module Masq
  class PasswordsController < ApplicationController
    before_filter :check_can_change_password, :only => [:create, :edit, :update]
    before_filter :find_account_by_reset_code, :only => [:edit, :update]

    # Forgot password
    def create
      if account = Account.where(:email => params[:email], :activation_code => nil).first
        account.forgot_password!
        redirect_to login_path, :notice => t(:password_reset_link_has_been_sent)
      else
        flash[:alert] = t(:could_not_find_user_with_email_address)
        render :action => 'new'
      end
    end

    # Reset password
    def update
      unless params[:password].blank?
        if @account.update_attributes(
             :password              => params[:password],
             :password_confirmation => params[:password_confirmation]
           )
          redirect_to login_path, :notice => t(:password_reset)
        else
          flash[:alert] = t(:password_mismatch)
          render :action => 'edit'
        end
      else
        flash[:alert] = t(:password_cannot_be_blank)
        render :action => 'edit'
      end
    end

    private

    def find_account_by_reset_code
      @reset_code = params[:id]
      @account    = Account.find_by_password_reset_code(@reset_code) unless @reset_code.blank?
      redirect_to(forgot_password_path, :alert => t(:reset_code_invalid_try_again)) unless @account
    end

    def check_can_change_password
      render_404 unless Masq::Engine.config.masq['can_change_password']
    end
  end
end
