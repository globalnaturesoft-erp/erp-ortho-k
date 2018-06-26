class AddCachePurchaseDebtAmountToErpContactsContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_contacts_contacts, :cache_purchase_debt_amount, :decimal
  end
end
