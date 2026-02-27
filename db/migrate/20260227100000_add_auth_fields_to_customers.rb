class AddAuthFieldsToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :magic_token,            :string
    add_column :customers, :magic_token_expires_at, :datetime
    add_column :customers, :email_verified_at,      :datetime

    add_index :customers, :magic_token, unique: true
    add_index :customers, :email,       unique: true
  end
end
