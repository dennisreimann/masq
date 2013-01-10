module Masq
  class OpenIdRequest < ActiveRecord::Base
    validates_presence_of :token, :parameters

    before_validation :make_token, :on => :create

    #attr_accessible :parameters
    serialize :parameters, Hash

    def parameters=(params)
      self[:parameters] = params.is_a?(Hash) ? params.delete_if { |k,v| k.index('openid.') != 0 } : nil
    end

    def from_trusted_domain?
      host = URI.parse(parameters['openid.realm'] || parameters['openid.trust_root']).host
      unless Masq::Engine.config.masq['trusted_domains'].nil?
        Masq::Engine.config.masq['trusted_domains'].find { |domain| host.ends_with? domain }
      end
    end

    private

    def make_token
      self.token = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
  end
end
