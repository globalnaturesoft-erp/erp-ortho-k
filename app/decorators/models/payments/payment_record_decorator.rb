Erp::Payments::PaymentRecord.class_eval do
  # get report note
  def get_report_note
    str = []
    str << I18n.t(".erp.payments.backend.#{pay_receive}_#{payment_type_code}")
    if order.present?
      if (!order.patient.nil? or !order.patient_state.nil?)
        str << 'BN' + (' ' + order.patient_state_name if !order.patient.nil?) + (': ' + order.patient_name if !order.patient.nil?)
      end
    end
    str << description.to_s if description.present?
    return str.join(" - ")
  end
  
  def self.get_account_for_debt
    Erp::Payments::Account.find_by_name('CÔNG NỢ ĐẦU KỲ')
  end
end