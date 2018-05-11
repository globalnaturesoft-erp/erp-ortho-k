Erp::Qdeliveries::DeliveryDetail.class_eval do
  belongs_to :patient, class_name: "Erp::Contacts::Contact", foreign_key: :patient_id, optional: true
  belongs_to :patient_state, class_name: "Erp::OrthoK::PatientState", foreign_key: :patient_state_id, optional: true
  
  # get report name
  def get_report_name
    str = []
    if get_order.present?
      str << get_order.doctor_name if get_order.doctor_name.present?
      str << ('BN' + ((' ' + get_order.patient_state_name) if get_order.patient_state_name.present?) + ': ' + get_order.patient_name) if get_order.patient_name.present?
      str << get_order_code if !order_detail.nil?
      str << get_order.order_date.strftime("%d/%m/%Y") if !order_detail.nil?
      str << state_name if state_name.present?
    end
    return str.join(" - ")
  end
  
  def patient_name
    (patient.present? ? patient.name : '')
  end
  
  def patient_state_name
    (patient_state.present? ? patient_state.name : '')
  end
end
