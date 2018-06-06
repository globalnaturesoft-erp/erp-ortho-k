class AddSerialsToErpConsignmentsReturnDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_consignments_return_details, :serials, :string
  end
end
