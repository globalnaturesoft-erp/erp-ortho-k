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

    self.where("erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?)", order_query, product_return_query, payment_query)

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
      .payment_for_contact_orders(from_date: @from, to_date: @to)
      .select('supplier_id')

    product_return_query = Erp::Qdeliveries::Delivery.all_delivered
      .purchase_export_deliveries
      .get_deliveries_with_payment_for_contact(from_date: @from, to_date: @to)
      .select('supplier_id')

    payment_query = Erp::Payments::PaymentRecord.all_done
      .select('supplier_id')
      .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SUPPLIER).id)
      .where("payment_date >= ? AND payment_date <= ?", @from, @to)

    self.where("erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?) OR erp_contacts_contacts.id IN (?)", order_query, product_return_query, payment_query)

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
      i_name = 2
      i_phone = 3
      i_address = 4

      i_city = 5
      i_area = 6
      i_group = 7


      row_count = 1
      sheet.each_row_streaming do |row|
        # only rows with data
        if row_count >= 3 and row[i_name].value.present?
          contact = self.new
          contact.name = row[i_name].value.strip
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

          # Check if is BS/BV/BN
          if contact.name.include? "BV" or contact.name.include? "Bệnh viện"
            contact.contact_group = Erp::Contacts::ContactGroup.get_hospital
          elsif contact.name.include? "BS" or contact.name.include? "Bác sĩ"
            contact.contact_group = Erp::Contacts::ContactGroup.get_doctor
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
            # contact.save
            printf "%-20s %-20s %-20s %-20s\n #{contact.contact_group_name}", row[0].value, "SUCCESS", contact.contact_group_name, contact.name
          else
            printf "%-20s %-20s %-20s %-20s\n", row[0].value, "EXIST", contact.contact_group_name, contact.name
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
  
  # Get patient by state and date
  def self.get_patients_by_state(options={})
    patient_ids = Erp::Orders::Order.all_confirmed
    patient_ids = patient_ids.where(payment_for: options[:payment_for]) if options[:payment_for].present?
    patient_ids = patient_ids.where.not(patient_id: nil)      
    patient_ids = patient_ids.where(patient_state_id: options[:patient_state_id]) if options[:patient_state_id].present?
    
    if options[:from].present?
      patient_ids = patient_ids.where('order_date >= ?', options[:from].beginning_of_day)
    end

    if options[:to].present?
      patient_ids = patient_ids.where('order_date <= ?', options[:to].end_of_day)
    end
    
    patient_ids
  end
end
