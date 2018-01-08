class AddMustSameCodeToErpOrdersOrderDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_orders_order_details, :must_same_code, :boolean
  end
end
