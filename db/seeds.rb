# Default user
puts "Create default admin user"
Erp::User.destroy_all
user = Erp::User.create(
  email: "admin@orthok.com",
  password: "aA456321@",
  name: "Super Admin",
  backend_access: true,
  confirmed_at: Time.now-1.day,
  active: true
) if Erp::User.where(email: "admin@orthok.com").empty?



# Default contact groups
puts "Create default contact groups"
Erp::Contacts::ContactGroup.create_default_groups



# Default areas
puts "Create default areas"
Erp::Areas::Country.destroy_all
Erp::Areas::State.destroy_all
Erp::Areas::District.destroy_all

vn = Erp::Areas::Country.create(
  id: 1,
  name: "Việt Nam",
  code: "vn"
)
vn.save

`psql orthok_development < database/erp_areas.dump`


# Default taxes
puts "Create default taxes"
taxes = [['VAT 0%', 'VAT 0%', 0], ['VAT 10%', 'VAT 10%', 10]]
Erp::Taxes::Tax.all.destroy_all
taxes.each_with_index do |t,index|
    Erp::Taxes::Tax.create(
        name: taxes[index][0],
        short_name: taxes[index][1],
        scope: Erp::Taxes::Tax::TAX_SCOPE_SALES,
        computation: Erp::Taxes::Tax::TAX_COMPUTATION_PRICE,
        amount: taxes[index][2],
        creator_id: user.id
    )
end

# Default contacts
puts "Create default contacts"
Erp::Contacts::Engine.load_seed

# Default warehouses
puts "Create default warehouses"
Erp::Warehouses::Engine.load_seed

# Default products
puts "Create default products"
Erp::Products::Engine.load_seed
