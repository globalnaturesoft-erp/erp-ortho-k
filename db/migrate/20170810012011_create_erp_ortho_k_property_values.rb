class CreateErpOrthoKPropertyValues < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_ortho_k_property_values do |t|
      t.string :value

      t.timestamps
    end
  end
end
