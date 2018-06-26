Erp::Payments::PaymentRecord.class_eval do
  # get report note
  def get_report_note
    str = []
    str << I18n.t(".erp.payments.backend.#{pay_receive}_#{payment_type_code}")
    if order.present?
      if (!order.patient.nil? or !order.patient_state.nil?)
        str << "#{('BN ' + order.patient_state_name) if !order.patient.nil?}#{(': ' + order.patient_name) if !order.patient.nil?}"
      end
    end
    str << description.to_s if description.present?
    return str.join(" - ")
  end
  
  def self.get_account_for_debt
    Erp::Payments::Account.find_by_name('CÔNG NỢ ĐẦU KỲ')
  end
  
  # update cache sales debt amount //contact
  after_save :update_contact_cache_sales_debt_amount
  def update_contact_cache_sales_debt_amount
    if payment_type.present? and [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER)].include?(payment_type)
      if customer.present?
        customer.update_cache_sales_debt_amount
      end
    end
  end
  
  # update cache purchase debt amount //contact
  after_save :update_contact_cache_purchase_debt_amount
  def update_contact_cache_purchase_debt_amount
    if payment_type.present? and [Erp::Payments::PaymentType::find_by_code(Erp::Payments::PaymentType::CODE_SUPPLIER)].include?(payment_type)
      if supplier.present?
        supplier.update_cache_purchase_debt_amount
      end
    end
  end
end