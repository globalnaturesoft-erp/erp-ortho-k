class AddDoctorIdToErpOrdersOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_orders_orders, :doctor_id, :integer
  end
end
