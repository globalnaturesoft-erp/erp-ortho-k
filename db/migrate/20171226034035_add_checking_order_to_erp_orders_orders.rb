class AddCheckingOrderToErpOrdersOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_orders_orders, :checking_order, :decimal
  end
end
