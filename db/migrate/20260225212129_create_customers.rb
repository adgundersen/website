class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers, if_not_exists: true do |t|
      t.string :stripe_customer_id
      t.string :stripe_subscription_id
      t.string :email
      t.string :slug

      t.timestamps
    end

    add_column :customers, :created_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" } unless column_exists?(:customers, :created_at)
    add_column :customers, :updated_at, :datetime, null: false, default: -> { "CURRENT_TIMESTAMP" } unless column_exists?(:customers, :updated_at)
  end
end
