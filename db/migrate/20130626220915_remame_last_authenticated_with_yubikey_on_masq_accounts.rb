class RemameLastAuthenticatedWithYubikeyOnMasqAccounts < ActiveRecord::Migration
  def up
    # Rename the last last_authenticated_with_yubikey to be within the 30 char column name limit set by Oracle.
    if table_exists?(:masq_accounts) && column_exists?(:masq_accounts, :last_authenticated_with_yubikey)
      rename_column :masq_accounts, :last_authenticated_with_yubikey, :last_authenticated_by_yubi
    end
  end

  def down
  end
end
