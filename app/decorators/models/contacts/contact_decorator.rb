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
      i_address = 3
      i_city = 4
      i_area = 5
      i_group = 6
      i_phone = 7

      row_count = 1
      sheet.each_row_streaming do |row|
        # only rows with data
        if row_count >= 7 and row[i_name].value.present?
          contact = self.new

          contact.name = row[i_name].value.strip
          contact.address = row[i_address].value.to_s.strip
          contact.phone = row[i_phone].value.to_s.strip
          contact.creator = user
          contact.contact_type = self::TYPE_OTHER

          # find state
          state = Erp::Areas::State.where("LOWER(name) LIKE ? OR name LIKE ?", "%#{row[i_city].value.strip.downcase}%", "%#{row[i_city].value.strip}%").first
          contact.state_id = state.id

          # Check if is BS/BV/BN
          group_name = row[i_group].value.to_s
          if group_name.include? "BS"
            contact.contact_group = Erp::Contacts::ContactGroup.get_doctor
          elsif group_name.include?("BV") or group_name.include?("PK")
            contact.contact_group = Erp::Contacts::ContactGroup.get_hospital
          elsif group_name.include?("CTY")
            contact.contact_group = Erp::Contacts::ContactGroup.get_company
          end

          # KH or NCC
          if group_name.include?("NCC") or group_name.include?("NV")
            contact.is_supplier = true
          else
            contact.is_customer = true
          end

          puts 'saving.... ' + contact.name + ': '
          puts contact.valid?
          puts contact.errors.to_json
          puts '-------'

          # puts contact.to_json
          if Erp::Contacts::Contact.where(name: contact.name).empty?
            puts contact.save
          end
        end

        row_count += 1
      end

    end
  end
end
