Erp::Ability.class_eval do
  def ortho_k_ability(user)
    # sales
    can :sales_sales_orders_index, :all if user.get_permission(:sales, :sales, :orders, :index) == 'yes'
    can :sales_sales_orders_create, :all if user.get_permission(:sales, :sales, :orders, :create) == 'yes'
    
    can :sales_gift_givens_index, :all if user.get_permission(:sales, :gift_givens, :gift_givens, :index) == 'yes'
    can :sales_gift_givens_create, :all if user.get_permission(:sales, :gift_givens, :gift_givens, :create) == 'yes'
    
    can :sales_consignments_index, :all if user.get_permission(:sales, :consignments, :consignments, :index) == 'yes'
    can :sales_consignments_create, :all if user.get_permission(:sales, :consignments, :consignments, :create) == 'yes'
    
    can :sales_cs_returns_index, :all if user.get_permission(:sales, :consignments, :cs_returns, :index) == 'yes'
    can :sales_cs_returns_create, :all if user.get_permission(:sales, :consignments, :cs_returns, :create) == 'yes'
    
    can :sales_customer_prices_update, :all if user.get_permission(:sales, :prices, :customer_prices, :update) == 'yes'
    can :sales_customer_prices_update_general, :all if user.get_permission(:sales, :prices, :customer_prices, :update_general) == 'yes'
    
    # purchase
    can :purchase_purchase_orders_index, :all if user.get_permission(:purchase, :purchase, :orders, :index) == 'yes'
    can :purchase_purchase_orders_create, :all if user.get_permission(:purchase, :purchase, :orders, :create) == 'yes'
    
    can :purchase_products_purchase_estimation_stock_importing, :all if user.get_permission(:purchase, :products, :purchase_estimation, :stock_importing) == 'yes'
    can :purchase_products_purchase_estimation_purchasing_export, :all if user.get_permission(:purchase, :products, :purchase_estimation, :purchasing_export) == 'yes'
    can :purchase_products_purchase_estimation_product_area_config, :all if user.get_permission(:purchase, :products, :purchase_estimation, :product_area_config) == 'yes'
    
    can :purchase_supplier_prices_update, :all if user.get_permission(:purchase, :prices, :supplier_prices, :update) == 'yes'
    can :purchase_supplier_prices_update_general, :all if user.get_permission(:purchase, :prices, :supplier_prices, :update_general) == 'yes'
    
    
    # inventory
    can :inventory_qdeliveries_deliveries_index, :all if user.get_permission(:inventory, :qdeliveries, :deliveries, :index) == 'yes'
    
    can :inventory_qdeliveries_sales_export_create, :all if user.get_permission(:inventory, :qdeliveries, :sales_export, :create) == 'yes'
    can :inventory_qdeliveries_sales_import_create, :all if user.get_permission(:inventory, :qdeliveries, :sales_import, :create) == 'yes'
    can :inventory_qdeliveries_purchase_import_create, :all if user.get_permission(:inventory, :qdeliveries, :purchase_import, :create) == 'yes'
    can :inventory_qdeliveries_purchase_export_create, :all if user.get_permission(:inventory, :qdeliveries, :purchase_export, :create) == 'yes'
    can :inventory_qdeliveries_custom_import_create, :all if user.get_permission(:inventory, :qdeliveries, :custom_import, :create) == 'yes'
    can :inventory_qdeliveries_custom_export_create, :all if user.get_permission(:inventory, :qdeliveries, :custom_export, :create) == 'yes'
    
    can :inventory_order_stock_checks_schecks_check, :all if user.get_permission(:inventory, :order_stock_checks, :schecks, :check) == 'yes'
    can :inventory_order_stock_checks_schecks_approve_order, :all if user.get_permission(:inventory, :order_stock_checks, :schecks, :approve_order) == 'yes'
    
    can :inventory_products_warehouse_checks_with_state_index, :all if user.get_permission(:inventory, :products, :warehouse_checks_with_state, :index) == 'yes'
    can :inventory_products_warehouse_checks_with_state_create, :all if user.get_permission(:inventory, :products, :warehouse_checks_with_state, :create) == 'yes'
    
    can :inventory_products_warehouse_checks_with_stock_index, :all if user.get_permission(:inventory, :products, :warehouse_checks_with_stock, :index) == 'yes'
    can :inventory_products_warehouse_checks_with_stock_create, :all if user.get_permission(:inventory, :products, :warehouse_checks_with_stock, :create) == 'yes'
    
    can :inventory_products_warehouse_checks_with_damage_index, :all if user.get_permission(:inventory, :products, :warehouse_checks_with_damage, :index) == 'yes'
    can :inventory_products_warehouse_checks_with_damage_create, :all if user.get_permission(:inventory, :products, :warehouse_checks_with_damage, :create) == 'yes'
    
    can :inventory_products_states_index, :all if user.get_permission(:inventory, :products, :states, :index) == 'yes'
    can :inventory_products_states_create, :all if user.get_permission(:inventory, :products, :states, :create) == 'yes'
    
    can :inventory_products_brands_index, :all if user.get_permission(:inventory, :products, :brands, :index) == 'yes'
    can :inventory_products_brands_create, :all if user.get_permission(:inventory, :products, :brands, :create) == 'yes'
    
    can :inventory_products_properties_index, :all
    can :inventory_products_properties_create, :all if false
    
    can :inventory_products_categories_index, :all if user.get_permission(:inventory, :products, :categories, :index) == 'yes'
    can :inventory_products_categories_create, :all if user.get_permission(:inventory, :products, :categories, :create) == 'yes'
    
    can :inventory_products_products_index, :all if user.get_permission(:inventory, :products, :products, :index) == 'yes'
    can :inventory_products_products_create, :all if user.get_permission(:inventory, :products, :products, :create) == 'yes'
    can :inventory_products_products_list_split, :all if user.get_permission(:inventory, :products, :products, :list_split) == 'yes'
    can :inventory_products_products_combine, :all if user.get_permission(:inventory, :products, :products, :combine) == 'yes'
    can :inventory_products_products_split, :all if user.get_permission(:inventory, :products, :products, :split) == 'yes'
    can :inventory_products_products_export_to_excel, :all if user.get_permission(:inventory, :products, :products, :export_to_excel) == 'yes'
    can :inventory_products_products_import_from_excel, :all if user.get_permission(:inventory, :products, :products, :import_from_excel) == 'yes'
    can :inventory_products_products_view_stock, :all if user.get_permission(:inventory, :products, :products, :view_stock) == 'yes'
    can :inventory_products_products_import_export_history, :all if user.get_permission(:inventory, :products, :products, :import_export_history) == 'yes'
    
    # accounting / ke toan
    can :accounting_payments_payment_records_index, :all if user.get_permission(:accounting, :payments, :payment_records, :index) == 'yes'
    can :accounting_payments_payment_records_create, :all if user.get_permission(:accounting, :payments, :payment_records, :create) == 'yes'
    can :accounting_payments_payment_records_export_to_excel, :all if user.get_permission(:accounting, :payments, :payment_records, :export_to_excel) == 'yes'
    
    can :accounting_payments_accounts_index, :all if user.get_permission(:accounting, :payments, :accounts, :index) == 'yes'
    can :accounting_payments_accounts_create, :all if user.get_permission(:accounting, :payments, :accounts, :create) == 'yes'
    can :accounting_payments_accounts_payment_records_by_account, :all if user.get_permission(:accounting, :payments, :accounts, :payment_records_by_account) == 'yes'
    
    can :accounting_payments_payment_types_index, :all if user.get_permission(:accounting, :payments, :payment_types, :index) == 'yes'
    can :accounting_payments_payment_types_create, :all if user.get_permission(:accounting, :payments, :payment_types, :create) == 'yes'
    
    can :accounting_chase_chase_sales, :all if user.get_permission(:accounting, :chase, :chase, :sales) == 'yes'
    can :accounting_chase_chase_sales_return, :all if user.get_permission(:accounting, :chase, :chase, :sales_return) == 'yes'
    can :accounting_chase_chase_purchase, :all if user.get_permission(:accounting, :chase, :chase, :purchase) == 'yes'
    can :accounting_chase_chase_purchase_return, :all if user.get_permission(:accounting, :chase, :chase, :purchase_return) == 'yes'
    
    can :accounting_chase_liabilities_tracking_retail, :all if user.get_permission(:accounting, :chase, :liabilities_tracking, :retail) == 'yes'
    can :accounting_chase_liabilities_tracking_customer, :all if user.get_permission(:accounting, :chase, :liabilities_tracking, :customer) == 'yes'
    can :accounting_chase_liabilities_tracking_supplier, :all if user.get_permission(:accounting, :chase, :liabilities_tracking, :supplier) == 'yes'
    
    can :accounting_chase_commission_commission, :all if user.get_permission(:accounting, :chase, :commission, :commission) == 'yes'
    
    # contact / quan ly danh ba, so dia chi lien he
    can :contacts_contacts_index, :all if user.get_permission(:contacts, :contacts, :contacts, :index) == 'yes'
    can :contacts_contacts_create, :all if user.get_permission(:contacts, :contacts, :contacts, :create) == 'yes'
    
    can :contacts_patient_states_index, :all if user.get_permission(:contacts, :patient_states, :patient_states, :index) == 'yes'
    can :contacts_patient_states_create, :all if user.get_permission(:contacts, :patient_states, :patient_states, :create) == 'yes'
    can :create, Erp::OrthoK::PatientState do |patient_state|
      user.get_permission(:contacts, :patient_states, :patient_states, :create) == 'yes'
    end
    can :update, Erp::OrthoK::PatientState do |patient_state|
      user.get_permission(:contacts, :patient_states, :patient_states, :update) == 'yes'
    end
    can :set_active, Erp::OrthoK::PatientState do |patient_state|
      false
    end
    can :set_deleted, Erp::OrthoK::PatientState do |patient_state|
      user.get_permission(:contacts, :patient_states, :patient_states, :delete) == 'yes'
    end
    
    # thong ke / bao cao
    can :report_inventory_matrix, :all if user.get_permission(:report, :report, :inventory, :matrix) == 'yes'
    can :report_inventory_delivery, :all if user.get_permission(:report, :report, :inventory, :delivery) == 'yes'
    can :report_inventory_import_export, :all if user.get_permission(:report, :report, :inventory, :import_export) == 'yes'
    can :report_inventory_category_diameter, :all if user.get_permission(:report, :report, :inventory, :category_diameter) == 'yes'
    can :report_inventory_code_diameter, :all if user.get_permission(:report, :report, :inventory, :code_diameter) == 'yes'
    can :report_inventory_product, :all if user.get_permission(:report, :report, :inventory, :product) == 'yes'
    can :report_inventory_custom_product, :all if user.get_permission(:report, :report, :inventory, :custom_product) == 'yes'
    can :report_inventory_product_warehouse, :all if user.get_permission(:report, :report, :inventory, :product_warehouse) == 'yes'
    can :report_inventory_central_area, :all if user.get_permission(:report, :report, :inventory, :central_area) == 'yes'
    #can :report_inventory_custom_area, :all if user.get_permission(:report, :report, :inventory, :custom_area) == 'yes'
    can :report_inventory_custom_area_v2, :all if user.get_permission(:report, :report, :inventory, :custom_area_v2) == 'yes'
    can :report_inventory_outside_product, :all if user.get_permission(:report, :report, :inventory, :outside_product) == 'yes'
    can :report_inventory_warehouse, :all if user.get_permission(:report, :report, :inventory, :warehouse) == 'yes'
    can :report_inventory_product_request, :all if user.get_permission(:report, :report, :inventory, :product_request) == 'yes'
    can :report_inventory_product_ordered, :all if user.get_permission(:report, :report, :inventory, :product_ordered) == 'yes'
    
    can :report_sales_sell_and_return, :all if user.get_permission(:report, :report, :sales, :sell_and_return) == 'yes'
    can :report_sales_sales_details, :all if user.get_permission(:report, :report, :sales, :sales_details) == 'yes'
    can :report_sales_product_sold, :all if user.get_permission(:report, :report, :sales, :product_sold) == 'yes'
    can :report_sales_product_return_by_state, :all if user.get_permission(:report, :report, :sales, :product_return_by_state) == 'yes'
    can :report_sales_product_return_by_patient_state, :all if user.get_permission(:report, :report, :sales, :product_return_by_patient_state) == 'yes'
    can :report_sales_new_patient, :all if user.get_permission(:report, :report, :sales, :new_patient) == 'yes'
    can :report_sales_new_patient_v2, :all if user.get_permission(:report, :report, :sales, :new_patient_v2) == 'yes'
    
    can :report_accounting_pay_receive, :all if user.get_permission(:report, :report, :accounting, :pay_receive) == 'yes'
    can :report_accounting_synthesis_pay_receive, :all if user.get_permission(:report, :report, :accounting, :synthesis_pay_receive) == 'yes'
    can :report_accounting_sales_results, :all if user.get_permission(:report, :report, :accounting, :sales_results) == 'yes'
    can :report_accounting_sales_summary, :all if user.get_permission(:report, :report, :accounting, :sales_summary) == 'yes'
    can :report_accounting_income_statement, :all if user.get_permission(:report, :report, :accounting, :income_statement) == 'yes'
    can :report_accounting_cash_flow, :all if user.get_permission(:report, :report, :accounting, :cash_flow) == 'yes'
    can :report_accounting_customer_liabilities, :all if user.get_permission(:report, :report, :accounting, :customer_liabilities) == 'yes'
    can :report_accounting_supplier_liabilities, :all if user.get_permission(:report, :report, :accounting, :supplier_liabilities) == 'yes'
    can :report_accounting_liabilities_arising, :all if user.get_permission(:report, :report, :accounting, :liabilities_arising) == 'yes'
    can :report_accounting_statistics_liabilities, :all if user.get_permission(:report, :report, :accounting, :statistics_liabilities) == 'yes'
    
    # cai dat du lieu he thong (nguoi dung, phan quyen,...)
    if user == Erp::User.get_super_admin or user.get_permission(:options, :users, :users, :index) == 'yes'
      can :options_users_users_index, :all
    end
    
    if user == Erp::User.get_super_admin or user.get_permission(:options, :users, :user_groups, :index) == 'yes'
      can :options_users_user_groups_index, :all
    end
    
    # system (he thong / cau hinh / sao luu)
    can :system_periods_periods_index, :all if user.get_permission(:system, :periods, :periods, :index) == 'yes'
    can :system_periods_periods_create, :all if user.get_permission(:system, :periods, :periods, :create) == 'yes'
    can :system_periods_periods_update, :all if user.get_permission(:system, :periods, :periods, :update) == 'yes'
    can :system_periods_periods_delete, :all if user.get_permission(:system, :periods, :periods, :delete) == 'yes'
    
    can :system_taxes_taxes_index, :all if user.get_permission(:system, :periods, :periods, :index) == 'yes'
    can :system_taxes_taxes_create, :all if user.get_permission(:system, :periods, :periods, :create) == 'yes'
    can :system_taxes_taxes_update, :all if user.get_permission(:system, :periods, :periods, :update) == 'yes'
    can :system_taxes_taxes_delete, :all if user.get_permission(:system, :periods, :periods, :delete) == 'yes'
    
    can :system_areas_countries_index, :all if user.get_permission(:system, :areas, :countries, :index) == 'yes'
    can :system_areas_countries_create, :all if user.get_permission(:system, :areas, :countries, :create) == 'yes'
    can :system_areas_countries_update, :all if user.get_permission(:system, :areas, :countries, :update) == 'yes'
    can :system_areas_countries_delete, :all if user.get_permission(:system, :areas, :countries, :delete) == 'yes'
    can :system_areas_states_index, :all if user.get_permission(:system, :areas, :states, :index) == 'yes'
    can :system_areas_states_create, :all if user.get_permission(:system, :areas, :states, :create) == 'yes'
    can :system_areas_states_update, :all if user.get_permission(:system, :areas, :states, :update) == 'yes'
    can :system_areas_states_delete, :all if user.get_permission(:system, :areas, :states, :delete) == 'yes'
    
    # cancan user (devise)
    # NOTE: u - la tai khoan trong danh sach; user - la tai khoan dang dang nhap/current_user 
    can :create, Erp::User do |u|
      user == Erp::User.get_super_admin or
      user.get_permission(:options, :users, :users, :create) == 'yes'
    end
    
    can :listview, Erp::User do |u|
      
    end
    
    can :update, Erp::User do |u|
      user == Erp::User.get_super_admin or
      (
        u != Erp::User.get_super_admin and
        user.get_permission(:options, :users, :users, :update) == 'yes'
      )
    end
    
    can :activate, Erp::User do |u|
      !u.active? and # active is false
      (
        user == Erp::User.get_super_admin or
        (
          u != Erp::User.get_super_admin and
          user.get_permission(:options, :users, :users, :activate) == 'yes'
        )
      )
    end
    
    can :deactivate, Erp::User do |u|
      u.active? and # active is true
      (
        user == Erp::User.get_super_admin or
        (
          u != Erp::User.get_super_admin and
          user.get_permission(:options, :users, :users, :deactivate) == 'yes'
        )
      )
    end
    
    # cancan user group
    can :create, Erp::UserGroup do |user_group|
      user == Erp::User.get_super_admin or
      user.get_permission(:options, :users, :user_groups, :create) == 'yes'
    end
    
    can :update, Erp::UserGroup do |user_group|
      user == Erp::User.get_super_admin or
      (
        user == Erp::User.get_super_admin or
        user.get_permission(:options, :users, :user_groups, :update) == 'yes'
      )
    end
    
    ## SIDEBAR MENU - START ##
    # app menus ability
    can :menu_sales, :all if user.get_permission(:sales, :sales, :orders, :index) == 'yes'
    can :menu_inventory, :all if user.get_permission(:inventory, :products, :products, :index) == 'yes'
    can :menu_accounting, :all if user.get_permission(:accounting, :payments, :payment_records, :index) == 'yes'
    can :menu_contact, :all if user.get_permission(:contacts, :contacts, :contacts, :index) == 'yes'
    can :menu_option, :all if user.get_permission(:options, :users, :users, :index) == 'yes'
    can :menu_system, :all if user.get_permission(:system, :periods, :periods, :index) == 'yes'
    ## SIDEBAR MENU - END ##
  end
end
