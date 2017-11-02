Erp::Contacts::Contact.class_eval do
    has_many :patient_orders, class_name: 'Erp::Orders::Order', foreign_key: :patient_id
end
