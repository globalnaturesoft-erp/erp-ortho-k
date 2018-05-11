class AddPatientToErpQdeliveriesDeliveryDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_qdeliveries_delivery_details, :patient_id, :integer
    add_column :erp_qdeliveries_delivery_details, :patient_state_id, :integer
  end
end
