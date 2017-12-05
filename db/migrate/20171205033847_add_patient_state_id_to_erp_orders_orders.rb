class AddPatientStateIdToErpOrdersOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_orders_orders, :patient_state_id, :integer
  end
end
