class CreateErpOrthoKPatientStates < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_ortho_k_patient_states do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
