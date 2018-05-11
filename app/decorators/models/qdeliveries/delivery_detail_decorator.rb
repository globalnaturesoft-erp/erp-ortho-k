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
  
  def get_patient
    # patient from order first
    if self.delivery.get_related_order.present?
      return delivery.get_related_order.patient
    end
    
    #
    return self.patient
  end
  
  def get_patient_name
    self.get_patient.present? ? self.get_patient.name : ''
  end
  
  def get_patient_state
    # patient from order first
    if self.delivery.get_related_order.present?
      return self.delivery.get_related_order.patient_state
    end
    
    #
    return self.patient_state
  end
  
  def get_patient_state_name
    self.get_patient_state.present? ? self.get_patient_state.name : ''
  end
end
