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

    if params[:remove_ids].present?
      query = query.where.not(id: params[:remove_ids].split(','))
    end

    query = query.includes(:children).where(children_erp_products_categories: {id: nil})

    query = query.limit(20).map{|category| {value: category.id, text: category.name} }
  end

  # get LEN category
  def self.get_len
    self.where(name: 'LEN').first
  end

  # get LEN categories
  def self.get_lens
    pid = self.get_len.present? ? self.get_len.id : -1
    self.where("parent_id = ? OR id = ?", pid, pid)
  end
end
