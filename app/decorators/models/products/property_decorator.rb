Erp::Products::Property.class_eval do
  NAME_DUONG_KINH = 'Đường kính'
  NAME_CHU = "Chữ"
  NAME_DO = 'Độ'
  NAME_SO = 'Số'
  NAME_DO_K = "Độ K"

  def self.getByName(name)
    return self.where(name: name).first
  end

  # data for dataselect ajax
  def self.dataselect(keyword='')
    options = []

    pchu = self.getByName(self::NAME_CHU)
    pdo = self.getByName(self::NAME_DO)
    pso = self.getByName(self::NAME_SO)
    pdok = self.getByName(self::NAME_DO_K)
    options += [
      {text: "#{pdo.name}-#{pchu.name}", value: "#{pdo.id}-#{pchu.id}"},
      {text: "#{pdok.name}-#{pso.name}", value: "#{pdok.id}-#{pso.id}"},
    ]

    query = self.all
    if keyword.present?
      keyword = keyword.strip.downcase
      query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
    end
    options += query.limit(8).map{|property| {value: property.id, text: property.name} }

    return options
  end
end
