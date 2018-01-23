class AddOrderedCodeToErpProductsProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_products_products, :ordered_code, :string
  end
end
