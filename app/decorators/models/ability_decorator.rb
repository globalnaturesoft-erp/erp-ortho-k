Erp::Ability.class_eval do
  def ortho_k_ability(user)
    # app menus ability
    can :menu_sales, :all if user.get_permission(:sales, :sales, :orders, :index) == 'yes'
    can :menu_inventory, :all if user.get_permission(:inventory, :products, :products, :index) == 'yes'
    can :menu_accounting, :all if user.get_permission(:accounting, :payments, :payment_records, :index) == 'yes'
    can :menu_option, :all if user.get_permission(:options, :users, :users, :index) == 'yes'
    can :menu_system, :all if user.get_permission(:system, :system, :system, :settings) == 'yes'
  end
end
