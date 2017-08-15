class CreateErpOrthoKCentralAreas < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_ortho_k_central_areas do |t|
      t.string :name

      t.timestamps
    end
  end
end
