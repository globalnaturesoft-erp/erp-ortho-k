Erp::Ability.class_eval do
  def ortho_k_ability(user)
    # app menus ability
    can :menu_sales, :all if user.get_permission(:sales, :sales, :orders, :index) == 'yes'
    can :menu_inventory, :all if user.get_permission(:inventory, :products, :products, :index) == 'yes'
    can :menu_accounting, :all if user.get_permission(:accounting, :payments, :payment_records, :index) == 'yes'
    can :menu_option, :all if user.get_permission(:options, :users, :users, :index) == 'yes'
    can :menu_system, :all if user.get_permission(:system, :system, :system, :settings) == 'yes'
    can :menu_contact, :all if user.get_permission(:contacts, :contacts, :contacts, :index) == 'yes'
    
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
    
  end
end
