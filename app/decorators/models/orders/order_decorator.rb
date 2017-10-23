Erp::Orders::Order.class_eval do
  belongs_to :doctor, class_name: "Erp::Contacts::Contact", foreign_key: :doctor_id, optional: true
  belongs_to :patient, class_name: "Erp::Contacts::Contact", foreign_key: :patient_id, optional: true
  belongs_to :hospital, class_name: "Erp::Contacts::Contact", foreign_key: :hospital_id, optional: true

  def doctor_name
    (doctor.present? ? doctor.name : '')
  end

  def patient_name
    (patient.present? ? patient.name : '')
  end

  def hospital_name
    (hospital.present? ? hospital.name : '')
  end

  def display_customer_info
    strs = []
    strs << doctor.name if doctor.present?
    strs << patient.name if patient.present?

    (strs.empty? ? '' : "(#{strs.join(' / ')})")
  end
end
