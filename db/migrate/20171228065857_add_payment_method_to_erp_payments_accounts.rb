class AddPaymentMethodToErpPaymentsAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_payments_accounts, :payment_method, :string
  end
end
