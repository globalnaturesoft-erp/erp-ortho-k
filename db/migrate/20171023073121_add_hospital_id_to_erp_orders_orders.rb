class AddHospitalIdToErpOrdersOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_orders_orders, :hospital_id, :integer
  end
end
