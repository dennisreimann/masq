require 'digest/sha1'

module Masq
  class Account < ActiveRecord::Base
    has_many :personas, ->(){order(:id)}, :dependent => :delete_all
    has_many :sites, :dependent => :destroy
    belongs_to :public_persona, :class_name => "Persona"

    validates_presence_of :login
    validates_length_of :login, :within => 3..254
    validates_uniqueness_of :login, :case_sensitive => false
    validates_format_of :login, :with => /\A[A-Za-z0-9_@.-]+\z/
    validates_presence_of :email
    validates_uniqueness_of :email, :case_sensitive => false
    validates_format_of :email, :with => /(\A([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})\z)/i, :allow_blank => true
    validates_presence_of :password, :if => :password_required?
    validates_presence_of :password_confirmation, :if => :password_required?
    validates_length_of :password, :within => 6..40, :if => :password_required?
    validates_confirmation_of :password, :if => :password_required?
    # check `rake routes' for whether this list is still complete when routes are changed
    validates_exclusion_of :login, :in => %w[account session password help safe-login forgot_password reset_password login logout server consumer]

    before_save   :encrypt_password
    after_save    :deliver_forgot_password

    #attr_accessible :login, :email, :password, :password_confirmation, :public_persona_id, :yubikey_mandatory
    attr_accessor :password

    class ActivationCodeNotFound < StandardError; end
    class AlreadyActivated < StandardError
      attr_reader :user, :message
      def initialize(account, message=nil)
        @message, @account = message, account
      end
    end

    # Finds the user with the corresponding activation code, activates their account and returns the user.
    #
    # Raises:
    # [Account::ActivationCodeNotFound] if there is no user with the corresponding activation code
    # [Account::AlreadyActivated] if the user with the corresponding activation code has already activated their account
    def self.find_and_activate!(activation_code)
      raise ArgumentError if activation_code.nil?
      user = find_by_activation_code(activation_code)
      raise ActivationCodeNotFound unless user
      raise AlreadyActivated.new(user) if user.active?
      user.send(:activate!)
      user
    end

    def to_param
      login
    end

    # The existence of an activation code means they have not activated yet
    def active?
      activation_code.nil?
    end

    def activate!
      @activated = true
      self.activated_at = Time.now.utc
      self.activation_code = nil
      self.save
    end

    # True if the user has just been activated
    def pending?
      @activated
    end

    # Does the user have the possibility to authenticate with a one time password?
    def has_otp_device?
      !yubico_identity.nil?
    end

    # Authenticates a user by their login name and password.
    # Returns the user or nil.
    def self.authenticate(login, password, basic_auth_used=false)
      a = Account.find_by_login(login)
      if a.nil? and Masq::Engine.config.masq['create_auth_ondemand']['enabled']
        # Need to set some password - but is never used
        if Masq::Engine.config.masq['create_auth_ondemand']['random_password']
          pw = SecureRandom.hex(13)
        else
          pw = password
        end
        signup = Signup.create_account!(
          :login => login,
          :password => pw,
          :password_confirmation => pw,
          :email => "#{login}@#{Masq::Engine.config.masq['create_auth_ondemand']['default_mail_domain']}")
        a = signup.account if signup.succeeded?
      end

      if not a.nil? and a.active? and a.enabled
        if a.authenticated?(password) or (Masq::Engine.config.masq['trust_basic_auth'] and basic_auth_used)
          a.last_authenticated_at, a.last_authenticated_with_yubikey = Time.now, a.authenticated_with_yubikey?
          a.save(:validate => false)
          return a
        end
      end
    end

    # Encrypts some data with the salt.
    def self.encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end

    # Encrypts the password with the user salt
    def encrypt(password)
      self.class.encrypt(password, salt)
    end

    def authenticated?(password)
      if password.nil?
        return false
      elsif password.length < 50 && !(yubico_identity? && yubikey_mandatory?)
        encrypt(password) == crypted_password
      elsif Masq::Engine.config.masq['can_use_yubikey']
        password, yubico_otp = Account.split_password_and_yubico_otp(password)
        encrypt(password) == crypted_password && @authenticated_with_yubikey = yubikey_authenticated?(yubico_otp)
      end
    end

    # Is the Yubico OTP valid and belongs to this account?
    def yubikey_authenticated?(otp)
      if yubico_identity? && Account.verify_yubico_otp(otp)
        (Account.extract_yubico_identity_from_otp(otp) == yubico_identity)
      else
        false
      end
    end

    def authenticated_with_yubikey?
      @authenticated_with_yubikey || false
    end

    def associate_with_yubikey(otp)
      if Account.verify_yubico_otp(otp)
        self.yubico_identity = Account.extract_yubico_identity_from_otp(otp)
        save(:validate => false)
      else
        false
      end
    end

    def remember_token?
      remember_token_expires_at && Time.now.utc < remember_token_expires_at
    end

    # These create and unset the fields required for remembering users between browser closes
    def remember_me
      remember_me_for 2.weeks
    end

    def remember_me_for(time)
      remember_me_until time.from_now.utc
    end

    def remember_me_until(time)
      self.remember_token_expires_at = time
      self.remember_token = encrypt("#{email}--#{remember_token_expires_at}")
      save(:validate => false)
    end

    def forget_me
      self.remember_token_expires_at = nil
      self.remember_token = nil
      save(:validate => false)
    end

    def forgot_password!
      @forgotten_password = true
      make_password_reset_code
      save
    end

    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    def reset_password
      update_attribute(:password_reset_code, nil)
      @reset_password = true
    end

    def recently_forgot_password?
      @forgotten_password
    end

    def recently_reset_password?
      @reset_password
    end

    def disable!
      update_attribute(:enabled, false)
    end

    protected

    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def make_password_reset_code
      self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end

    private

    # Returns the first twelve chars from the Yubico OTP,
    # which are used to identify a Yubikey
    def self.extract_yubico_identity_from_otp(yubico_otp)
      yubico_otp[0..11]
    end

    # Recieves a login token which consists of the users password and
    # a Yubico one time password (the otp is always 44 characters long)
    def self.split_password_and_yubico_otp(token)
      token.reverse!
      yubico_otp = token.slice!(0..43).reverse
      password = token.reverse
      [password, yubico_otp]
    end

    # Utilizes the Yubico library to verify an one time password
    def self.verify_yubico_otp(otp)
      begin
        Yubikey::OTP::Verify.new(otp).valid?
      rescue Yubikey::OTP::InvalidOTPError
        false
      end
    end

    def deliver_forgot_password
      AccountMailer.forgot_password(self).deliver if recently_forgot_password?
    end

  end
end
