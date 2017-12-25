Erp::Products::PropertiesValue.class_eval do
  def self.letter_values
    self.where(property_id: Erp::Products::Property.get_letter.id)
  end

  def self.letter_value_options
    self.letter_values.map {|row| {text: row.value, value: row.id} }
  end

  def self.number_values
    self.where(property_id: Erp::Products::Property.get_number.id)
  end

  def self.number_value_options
    self.number_values.map {|row| {text: row.value, value: row.id} }
  end

  def self.diameter_values
    self.where(property_id: Erp::Products::Property.get_diameter.id)
  end

  def self.diameter_value_options
    self.diameter_values.map {|row| {text: row.value, value: row.id} }
  end
end
