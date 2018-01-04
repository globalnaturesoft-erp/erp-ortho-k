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

    end
  end
end
