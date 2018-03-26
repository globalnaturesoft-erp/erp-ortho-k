class AddStatusToErpOrthoKPatientStates < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_ortho_k_patient_states, :status, :string
  end
end
