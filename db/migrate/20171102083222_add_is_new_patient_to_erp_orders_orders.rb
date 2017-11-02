class AddIsNewPatientToErpOrdersOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_orders_orders, :is_new_patient, :boolean, default: false
  end
end
