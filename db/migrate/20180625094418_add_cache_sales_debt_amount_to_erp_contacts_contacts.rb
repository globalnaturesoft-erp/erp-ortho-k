class AddCacheSalesDebtAmountToErpContactsContacts < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_contacts_contacts, :cache_sales_debt_amount, :decimal
  end
end
