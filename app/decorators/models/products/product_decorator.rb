Erp::Products::Product.class_eval do
  # get diameter value
  def get_value(property)
    return nil if !property.present?
    
    cache = JSON.parse(self.cache_properties)
    (cache[property.id.to_s].present? and cache[property.id.to_s][1].present?) ? cache[property.id.to_s][1] : nil
  end

  # get diameter
  def get_diameter
    self.get_value(Erp::Products::Property.getByName(Erp::Products::Property::NAME_DUONG_KINH))
  end
end
