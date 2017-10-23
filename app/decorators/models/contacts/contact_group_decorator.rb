Erp::Contacts::ContactGroup.class_eval do
  # default group
  GROUP_PATIENT = 1
  GROUP_DOCTOR = 2
  GROUP_HOSPITAL = 3

  def self.create_default_groups
    # Contact group
    self.destroy_all

    puts self.create(
      id: GROUP_PATIENT,
      name: 'Bệnh nhân',
    ).errors.to_json
    self.create(
      id: GROUP_DOCTOR,
      name: 'Bác sĩ',
    )
    self.create(
      id: GROUP_HOSPITAL,
      name: 'Bệnh viện/Phòng khám',
    )
  end

  def self.get_doctor
    return self.find(GROUP_DOCTOR)
  end

  def self.get_hospital
    return self.find(GROUP_HOSPITAL)
  end

  def self.get_patient
    return self.find(GROUP_PATIENT)
  end
end
