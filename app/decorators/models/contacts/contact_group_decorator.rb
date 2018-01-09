Erp::Contacts::ContactGroup.class_eval do
  # default group
  GROUP_PATIENT = 1
  GROUP_DOCTOR = 2
  GROUP_HOSPITAL = 3
  GROUP_COMPANY = 4
  GROUP_CLINIC = 5
  GROUP_RETAIL_CUSTOMER = 6
  GROUP_PHARMACY = 7

  def self.create_default_groups
    # Contact group
    self.destroy_all

    self.create(
      id: GROUP_PATIENT,
      name: 'Bệnh nhân',
    )
    self.create(
      id: GROUP_DOCTOR,
      name: 'Bác sĩ',
    )
    self.create(
      id: GROUP_HOSPITAL,
      name: 'Bệnh viện',
    )
    self.create(
      id: GROUP_COMPANY,
      name: 'Công ty',
    )
    self.create(
      id: GROUP_CLINIC,
      name: 'Phòng khám',
    )
    self.create(
      id: GROUP_RETAIL_CUSTOMER,
      name: 'Khách lẻ',
    )
    self.create(
      id: GROUP_PHARMACY,
      name: 'Nhà thuốc',
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

  def self.get_company
    return self.find(GROUP_COMPANY)
  end

  def self.get_clinic
    return self.find(GROUP_CLINIC)
  end

  def self.get_retail_customer
    return self.find(GROUP_RETAIL_CUSTOMER)
  end

  def self.get_pharmacy
    return self.find(GROUP_PHARMACY)
  end
end
