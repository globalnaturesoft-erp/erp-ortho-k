class AddIsOutsideToErpProductsProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_products_products, :is_outside, :boolean, default: false
  end
end
