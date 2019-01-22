Erp::Contacts::Contact.class_eval do
  has_many :patient_orders, class_name: 'Erp::Orders::Order', foreign_key: :patient_id

  # import init stock from file
  def self.import_init_contacts(file)
    # config
    timestamp = Time.now.to_i
    xlsx = Roo::Spreadsheet.open(file)
    user = Erp::User.first

    # Read excel file. sheet tabs loop
    xlsx.each_with_pagename do |name, sheet|
      headers = sheet.row(6)

      # data posistion
      i_num = 0
      i_name = 2
      i_address = 4
      i_city = 5
      i_area = 6
      i_group = 7
      i_phone = 8

      row_count = 1
      sheet.each_row_streaming do |row|
        # only rows with data
        if row_count >= 7 and row[i_name].value.present?
          contact = self.new
          contact.name = row[i_name].value.strip
          contact.address = row[i_address].value.to_s.strip if row[i_address].present?
          contact.phone = row[i_phone].value.to_s.strip if row[i_phone].present?
          contact.creator = user
          contact.contact_type = self::TYPE_OTHER


          # find state
          city_name = row[i_city].value.strip
          city_name = 'Đắk Lắk' if city_name == 'Đaklak'
          city_name = 'Đắk Nông' if city_name == 'Đaknong'
          city_name = 'Hồ Chí Minh' if city_name == 'Sài Gòn'
          city_name = 'Khánh Hòa' if city_name == 'Nha Trang'

          state = Erp::Areas::State.where("LOWER(name) LIKE ? OR name LIKE ?", "%#{city_name.downcase}%", "%#{city_name}%").first
          contact.state_id = state.id

          # Check if is BS/BV/BN
          if contact.name.include? "BV"
            contact.contact_group = Erp::Contacts::ContactGroup.get_hospital
          elsif contact.name.include?("PK")
            contact.contact_group = Erp::Contacts::ContactGroup.get_clinic
          elsif contact.name.include?("CTY")
            contact.contact_group = Erp::Contacts::ContactGroup.get_company
          elsif contact.name.include?("NHÀ THUỐC")
            contact.contact_group = Erp::Contacts::ContactGroup.get_pharmacy
          elsif contact.name.include?("KHÁCH LẺ")
            contact.contact_group = Erp::Contacts::ContactGroup.get_retail_customer
          end

          # KH or NCC
          if contact.name.include?("NCC") or contact.name.include?("NV")
            contact.is_supplier = true
          else
            contact.is_customer = true
          end

          # puts contact.to_json
          exist = Erp::Contacts::Contact.where(name: contact.name).first
          if exist.nil?
            contact.save
            printf "%-20s %-20s %-20s %-20s\n", row[0].value, "SUCCESS", contact.contact_group_name, contact.name
          else
            printf "%-20s %-20s %-20s %-20s\n", row[0].value, "EXIST", contact.contact_group_name, contact.name
          end
        end

        row_count += 1
      end

      # Child
      i_parent = 2
      i_name = 3
      row_count = 1
      sheet.each_row_streaming do |row|
        # only rows with data
        if row_count >= 7 and row[i_name].present? and row[i_name].value.present?
          contact = self.new

          contact.name = row[i_name].value.strip
          contact.address = row[i_address].value.to_s.strip
          contact.phone = row[i_phone].value.to_s.strip
          contact.creator = user
          contact.contact_type = self::TYPE_OTHER

          # find state
          city_name = row[i_city].value.strip
          city_name = 'Đắk Lắk' if city_name == 'Đaklak'
          city_name = 'Đắk Nông' if city_name == 'Đaknong'
          city_name = 'Hồ Chí Minh' if city_name == 'Sài Gòn'
          city_name = 'Khánh Hòa' if city_name == 'Nha Trang'
          state = Erp::Areas::State.where("LOWER(name) LIKE ? OR name LIKE ?", "%#{city_name.downcase}%", "%#{city_name}%").first
          contact.state_id = state.id

          # Check if is BS/BV/BN
          if contact.name.include? "BV"
            contact.contact_group = Erp::Contacts::ContactGroup.get_hospital
          elsif contact.name.downcase.include?("pk")
            contact.contact_group = Erp::Contacts::ContactGroup.get_clinic
          elsif contact.name.downcase.include?("cty")
            contact.contact_group = Erp::Contacts::ContactGroup.get_company
          elsif contact.name.include?("NHÀ THUỐC")
            contact.contact_group = Erp::Contacts::ContactGroup.get_pharmacy
          elsif contact.name.include?("KHÁCH LẺ")
            contact.contact_group = Erp::Contacts::ContactGroup.get_retail_customer
          elsif contact.name.downcase.include?("bs")
            contact.contact_group = Erp::Contacts::ContactGroup.get_doctor
          end

          # KH or NCC
          if contact.name.include?("NCC") or contact.name.include?("NV")
            contact.is_supplier = true
          else
            contact.is_customer = true
          end

          # parent
          if row[i_parent].present? and row[i_parent].value.present?
            parent_name = row[i_parent].value.strip
            parent = Erp::Contacts::Contact.where(name: parent_name).first
            contact.parent_id = parent.id if parent.present?
          end

          # puts contact.to_json
          exist = Erp::Contacts::Contact.where(name: contact.name, parent_id: contact.parent_id).first
          if exist.nil?
            contact.save
            printf "%-20s %-20s %-20s %-40s %-20s\n", row[0].value, "SUCCESS", contact.contact_group_name, contact.name, contact.parent_name
          else
            printf "%-20s %-20s %-20s %-40s %-20s\n", row[0].value, "EXIST", contact.contact_group_name, contact.name, contact.parent_name
          end
        end

        row_count += 1
      end
    end

  end

  # get contacts list for payment chasing
  def self.get_sales_payment_chasing_contacts(options={})
    @from = options[:from_date]
    @to = options[:to_date]

    # Loc danh sach cac khach hang co phat sinh giao dich (thanh toan, cong no)
    order_query = Erp::Orders::Order.all_confirmed
      .sales_orders
      .payment_for_contact_orders(from_date: @from, to_date: @to)
      .select('customer_id')

    product_return_query = Erp::Qdeliveries::Delivery.all_delivered
      .sales_import_deliveries
      .get_deliveries_with_payment_for_contact(from_date: @from, to_date: @to)
      .select('customer_id')

    payment_query = Erp::Payments::PaymentRecord.all_done
      .select('customer_id')
      .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id)
      .where("payment_date >= ? AND payment_date <= ?", @from, @to)
    
    self.where("erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?)",
               order_query, product_return_query, payment_query)

    #ids = [-1]
    #self.all.each do |c|
    #  if c.sales_debt_amount > 0.0
    #    ids << c.id
    #  end
    #end
    #
    #self.where("id IN (?) OR id IN (?) OR id IN (?) OR id IN (?)", order_query, product_return_query, payment_query, ids)
  end

  # get contacts list for payment chasing
  def self.get_purchase_payment_chasing_contacts(options={})
    @from = options[:from_date]
    @to = options[:to_date]

    # Loc danh sach cac khach hang co phat sinh giao dich (thanh toan, cong no)
    order_query = Erp::Orders::Order.all_confirmed
      .purchase_orders
      .payment_for_contact_orders #(from_date: @from, to_date: @to)
      .select('supplier_id')

    product_return_query = Erp::Qdeliveries::Delivery.all_delivered
      .purchase_export_deliveries
      .get_deliveries_with_payment_for_contact #(from_date: @from, to_date: @to)
      .select('supplier_id')

    payment_query = Erp::Payments::PaymentRecord.all_done
      .select('supplier_id')
      .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SUPPLIER).id)
      #.where("payment_date >= ? AND payment_date <= ?", @from, @to)

    self.where("erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?)",
               order_query, product_return_query, payment_query)

    #ids = [-1]
    #self.all.each do |c|
    #  if c.purchase_debt_amount > 0.0
    #    ids << c.id
    #  end
    #end
    #
    #self.where("id IN (?) OR id IN (?) OR id IN (?) OR id IN (?)", order_query, product_return_query, payment_query, ids)
  end

  # import init stock from file
  def self.import_init_contacts_hn(file)
    # config
    timestamp = Time.now.to_i
    xlsx = Roo::Spreadsheet.open(file)
    user = Erp::User.first

    # Read excel file. sheet tabs loop
    xlsx.each_with_pagename do |name, sheet|
      headers = sheet.row(6)

      # data posistion
      i_num = 0
      i_code = 1
      i_name = 2
      i_phone = 9
      i_address = 6
      i_group = 5
      i_type_2 = 4
      i_type = 3
      i_parent = 11
      
      i_district = 7
      i_city = 8
      i_salesperson = 12
      i_commission_percent = 13


      row_count = 1
      sheet.each_row_streaming do |row|
        # only rows with data
        if row_count >= 2 and row[i_name].value.present?
          contact = self.new
          contact.name = row[i_name].value.strip
          contact.code = row[i_code].value.strip
          contact.address = row[i_address].value.to_s.strip if row[i_address].present?
          contact.phone = row[i_phone].value.to_s.strip if row[i_phone].present?
          contact.creator = user
          contact.contact_type = self::TYPE_OTHER


          ## find state
          #city_name = row[i_city].value.strip
          #city_name = 'Đắk Lắk' if city_name == 'Đaklak'
          #city_name = 'Đắk Nông' if city_name == 'Đaknong'
          #city_name = 'Hồ Chí Minh' if city_name == 'Sài Gòn'
          #city_name = 'Khánh Hòa' if city_name == 'Nha Trang'
          #
          #state = Erp::Areas::State.where("LOWER(name) LIKE ? OR name LIKE ?", "%#{city_name.downcase}%", "%#{city_name}%").first
          #contact.state_id = state.id

          ## Check if is BS/BV/BN
          #if contact.name.include? "BV" or contact.name.include? "Bệnh viện"
          #  contact.contact_group = Erp::Contacts::ContactGroup.get_hospital
          #elsif contact.name.include? "BS" or contact.name.include? "Bác sĩ"
          #  contact.contact_group = Erp::Contacts::ContactGroup.get_doctor
          #elsif contact.name.include?("PK")
          #  contact.contact_group = Erp::Contacts::ContactGroup.get_clinic
          #elsif contact.name.include?("CTY")
          #  contact.contact_group = Erp::Contacts::ContactGroup.get_company
          #elsif contact.name.include?("NHÀ THUỐC")
          #  contact.contact_group = Erp::Contacts::ContactGroup.get_pharmacy
          #elsif contact.name.include?("KHÁCH LẺ")
          #  contact.contact_group = Erp::Contacts::ContactGroup.get_retail_customer
          #else
          #  contact.contact_group = Erp::Contacts::ContactGroup.get_company
          #end

          group = Erp::Contacts::ContactGroup.where("LOWER(name) = ? ", row[i_group].value.downcase.strip).first
          contact.contact_group = group
          
          # create group if not exist
          if group.nil?
            group = Erp::Contacts::ContactGroup.create(id: 8, name: row[i_group].value.strip)
          end
          
          # create user if group is Nhân viên
          if group.name == 'Nhân viên'
            user_email = contact.name.to_ascii.downcase.split(' ').last.strip + "."
            contact.name.to_ascii.downcase.split(' ')[0..-2].each do |word|
              user_email += word[0]
            end
            user_email += '@fargo.vn'
            
            user = Erp::User.where(email: user_email).first
            
            if user.nil?
              user = Erp::User.create(
                email: user_email,
                password: "aA456321@",
                name: contact.name,
                backend_access: true,
                confirmed_at: Time.now-1.day,
                active: true
              )
            end
            
            contact.user_id = user.id
          end

          # KH or NCC
          if row[i_type].value == 'Nhà cung cấp'
            contact.is_supplier = true
          else
            contact.is_customer = true
          end

          # ca nhan or to chuc
          if row[i_type_2].value == 'Cá nhân'
            contact.contact_type = 'person'
          else
            contact.contact_type = 'company'
          end

          # parent
          if row[i_parent].present?
            pa = self.where(code: row[i_parent].value).first
            contact.parent = pa
          end

          # puts contact.to_json
          exist = Erp::Contacts::Contact.where(name: contact.name).first
          
          # district
          if row[i_district].present?
            district_name = row[i_district].value
            
            district = Erp::Areas::District.where("name LIKE ? or LOWER(name) LIKE ?", district_name.strip, district_name.downcase.strip).first
            
            contact.district = district
          end
          
          # district
          if row[i_city].present?
            state_name = row[i_city].value
            
            state = Erp::Areas::State.where("name LIKE ? or LOWER(name) LIKE ?", state_name.strip, state_name.downcase.strip).first
            
            #puts "#{state.present?} - #{state_name}"
            
            contact.state = state
          end
          
          # country
          contact.country = Erp::Areas::Country.where(name: "Việt Nam").first
          
          # salesperson
          if row[i_salesperson].present?
            sp_name = row[i_salesperson].value
            
            salesperson = Erp::User.where(name: sp_name.strip).first
            
            contact.salesperson = salesperson
          end
          
          # salesperson    
          contact.commission_percent = row[i_commission_percent].value
          
          # contact.save
          printf "%-10s %-10s %-10s %-40s %-10s %-10s %-10s %-10s %-15s %-25s %-20s %-10s\n",
            row[i_num],
            (exist.nil? ? "SUCCESS" : "EXIST"),
            contact.code,
            contact.name[0..30],
            (contact.is_supplier ? "Supplier" : ((contact.is_customer ? "Customer" : '####'))),
            contact.contact_type,
            contact.contact_group_name,            
            (contact.user.present? ? contact.user.name : ''),
            (contact.state.present? ? contact.state.name : ''),
            (contact.district.present? ? contact.district.name : ''),
            (contact.salesperson.present? ? contact.salesperson.name : ''),
            contact.commission_percent
          
          exist = Erp::Contacts::Contact.where(name: contact.name).first
          
          if exist.nil?
            contact.save
            puts "#{contact.valid?} ########### SAVED"
            puts ""
          else
            puts "#{contact.valid?} ########### EXISTS"
            puts ""
          end
        end

        row_count += 1
      end
    end
  end
  
  # get contacts list for payment chasing // Don hang ban le/PK
  def self.get_sales_orders_tracking_payment_chasing_contacts(options={})
    @from = options[:from_date]
    @to = options[:to_date]

    # Loc danh sach cac khach hang co phat sinh giao dich (thanh toan, cong no)
    order_query = Erp::Orders::Order.all_confirmed
      .sales_orders
      .payment_for_order_orders(from_date: @from, to_date: @to)
      .select('customer_id')

    product_return_query = Erp::Qdeliveries::Delivery.all_delivered
      .sales_import_deliveries
      .get_deliveries_with_payment_for_order(from_date: @from, to_date: @to)
      .select('customer_id')

    payment_query = Erp::Payments::PaymentRecord.all_done
      .select('customer_id')
      .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER).id)
      .where("payment_date >= ? AND payment_date <= ?", @from, @to)
    
    #ids = [-1]
    #self.all.each do |c|
    #  if c.orders_tracking_sales_debt_amount > 0.0
    #    ids << c.id
    #  end
    #end

    self.where("erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?)", order_query, product_return_query, payment_query)
  end
  
  # get contacts list for payment chasing // Customer commission
  def self.get_customer_commission_payment_chasing_contacts(options={})
    @from = options[:from_date]
    @to = options[:to_date]

    # Loc danh sach cac khach hang co phat sinh giao dich (thanh toan, chiet khau)    
    order_query = Erp::Orders::Order.all_confirmed
      .sales_orders
      .payment_for_contact_orders#(from_date: @from, to_date: @to)
      .select('customer_id')
      .where("cache_customer_commission_amount != ?", 0.0)
    
    # @todo truong hop don hang co chiet khau nhung da bi tra lai (tinh sao?)
    
    #payment_query = Erp::Payments::PaymentRecord.all_done
    #  .select('customer_id')
    #  .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER_COMMISSION).id)
    #  .where("payment_date >= ? AND payment_date <= ?", @from, @to)

    self.where("erp_contacts_contacts.id IN (?)", order_query)
  end
  
  # Get patient by state and date
  def self.get_patients_by_state(options={})
    patient_ids = Erp::Orders::Order.all_confirmed
    patient_ids = patient_ids.where(payment_for: options[:payment_for]) if options[:payment_for].present?
    patient_ids = patient_ids.where.not(patient_id: nil)      
    patient_ids = patient_ids.where(patient_state_id: options[:patient_state_id]) if options[:patient_state_id].present?
    
    if options[:customer_id].present?
      patient_ids = patient_ids.where(customer_id: options[:customer_id])
    end
    
    if options[:from].present?
      patient_ids = patient_ids.where('order_date >= ?', options[:from].beginning_of_day)
    end

    if options[:to].present?
      patient_ids = patient_ids.where('order_date <= ?', options[:to].end_of_day)
    end
    
    patient_ids
  end
  
  # Get contact has returned products
  def self.get_has_sales_returned_qdeliveries(options={})
    query = Erp::Qdeliveries::DeliveryDetail.get_returned_confirmed_delivery_details(options)
    query = query.select('erp_qdeliveries_deliveries.customer_id')
    
    self.where(id: query)
  end
  
  # START - Update cache sales/purchase debt amount
  after_save :update_cache_sales_debt_amount
  def update_cache_sales_debt_amount
    self.update_column(:cache_sales_debt_amount, self.sales_debt_amount)
  end
  
  after_save :update_cache_purchase_debt_amount
  def update_cache_purchase_debt_amount
    self.update_column(:cache_purchase_debt_amount, self.purchase_debt_amount)
  end
  # END - Update cache sales/purchase debt amount
  
  def self.get_sales_debt_amount_residual_contacts(options={})
    self.all_active.where("erp_contacts_contacts.cache_sales_debt_amount != ?", 0.0)
  end
  
  def self.get_purchase_debt_amount_residual_contacts(options={})
    self.all_active.where("erp_contacts_contacts.cache_purchase_debt_amount != ?", 0.0)
  end
  
  # Get liabilities contacts //in_period_active and is_debt_active
  def self.get_sales_liabilities_contacts(options={})
    self.get_sales_payment_chasing_contacts(options).or(self.get_sales_debt_amount_residual_contacts)
  end
  
  def self.get_purchase_liabilities_contacts(options={})
    self.get_purchase_payment_chasing_contacts(options).or(self.get_purchase_debt_amount_residual_contacts)
  end
  
  # cache_sales_debt_amount
  def self.cache_sales_debt_amount
    self.sum("erp_contacts_contacts.cache_sales_debt_amount")
  end
  
  CONTACT_GROUPS_ALL = 'contact_all'
  CONTACT_GROUPS_FARGO_HN = 'contact_is_fargo_hn'
  CONTACT_GROUPS_NOT_FARGO_HN = 'contact_is_not_fargo_hn'
  
  def self.get_contact_groups()
    [
      {
        text: 'Tất cả các khách hàng',
        value: Erp::Products::Product::CONTACT_GROUPS_ALL
      },
      {
        text: 'Chi nhánh Fargo Hà Nội',
        value: Erp::Products::Product::CONTACT_GROUPS_FARGO_HN
      },
      {
        text: 'Không phải Fargo Hà Nội',
        value: Erp::Products::Product::CONTACT_GROUPS_NOT_FARGO_HN
      }
    ]
  end
  
  # data for dataselect ajax
  def self.dataselect(keyword='', params='')

    query = self.all_active

    if params[:contact_type].present?
      query = query.where(contact_type: params[:contact_type])
    end

    if params[:is_customer].present?
      query = query.where(is_customer: params[:is_customer])
    end

    if params[:is_supplier].present?
      query = query.where(is_supplier: params[:is_supplier])
    end

    if params[:contact_group_id].present?
      query = query.where(contact_group_id: params[:contact_group_id])
    end

    if params[:parent_id].present?
      query = query.where(parent_id: params[:parent_id])
    end
    
    if keyword.present?
      keyword = keyword.strip.downcase
      keyword.split(' ').each do |q|
        q = q.strip
        query = query.where('LOWER(erp_contacts_contacts.cache_search) LIKE ?', '%'+q.to_ascii.downcase+'%')
      end
    end

    if params[:contact_id].present?
      query = query.where.not(id: params[:contact_id])
    end
    
    if params[:contact_group_id] == Erp::Contacts::ContactGroup::GROUP_DOCTOR.to_s
      # style #1
      if params[:customer].present?
        query = query.where(parent_id: params[:customer])
      end
      
      # style #2
      if params[:customer_id].present?
        query = query.where(parent_id: params[:customer_id])
      end
    end
    
    if params[:contact_group_id] == Erp::Contacts::ContactGroup::GROUP_PATIENT.to_s      
      # style #1
      if params[:customer].present?
        if params[:doctor].present?
          query = query.where(parent_id: params[:doctor])
        else
          doctors_query = Erp::Contacts::Contact.where(parent_id: params[:customer])
          query = query.where(parent_id: doctors_query)
        end
      end
      
      # style #2
      if params[:customer_id].present?
        if params[:doctor_id].present?
          query = query.where(parent_id: params[:doctor_id])
        else
          doctors_query = Erp::Contacts::Contact.where(parent_id: params[:customer_id])
          query = query.where(parent_id: doctors_query)
        end
      end
    end

    query = query.limit(25).map{|contact| {value: contact.id, text: contact.contact_name} }
  end
end
