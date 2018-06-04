class AddSerialsToErpConsignmentsConsignmentDetails < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_consignments_consignment_details, :serials, :string
  end
end
