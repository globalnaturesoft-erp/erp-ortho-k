class CreateErpOrthoKCareasPvalues < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_ortho_k_careas_pvalues do |t|
      t.references :central_area, index: true, references: :erp_ortho_k_central_areas
      t.references :property_value, index: true, references: :erp_ortho_k_property_values

      t.timestamps
    end
  end
end
