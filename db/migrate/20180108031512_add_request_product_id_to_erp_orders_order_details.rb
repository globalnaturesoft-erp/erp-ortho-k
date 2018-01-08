class AddRequestProductIdToErpOrdersOrderDetails < ActiveRecord::Migration[5.1]
  def change
    add_reference :erp_orders_order_details, :request_product, index: true, references: :erp_products_products
  end
end
