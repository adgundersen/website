class AddStatusToCustomers < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :status, :string, default: "pending" unless column_exists?(:customers, :status)
  end
end
