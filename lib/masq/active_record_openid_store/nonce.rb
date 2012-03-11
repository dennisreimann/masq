module Masq
  class Nonce < ActiveRecord::Base
    self.table_name = 'masq_open_id_nonces'
  end
end
