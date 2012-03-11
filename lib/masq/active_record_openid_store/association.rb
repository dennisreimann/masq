require 'openid/association'

module Masq
  class Association < ActiveRecord::Base
    self.table_name = 'masq_open_id_associations'
    def from_record
      OpenID::Association.new(handle, secret, issued, lifetime, assoc_type)
    end
  end
end
