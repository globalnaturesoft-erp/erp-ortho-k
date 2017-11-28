class AddEyePositionToErpOrdersOrderDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_orders_order_details, :eye_position, :string
  end
end
