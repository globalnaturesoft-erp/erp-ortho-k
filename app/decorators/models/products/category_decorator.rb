Erp::Products::Category.class_eval do
  # data for dataselect ajax
  def self.dataselect(keyword='', params={})
    query = self.all

    if keyword.present?
      keyword = keyword.strip.downcase
      query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
    end

    if params[:current_value].present?
      query = query.where.not(id: params[:current_value].split(','))
    end

    query = query.limit(20).map{|category| {value: category.id, text: category.name} }
  end
end
