module Erp::OrthoK
  class CentralArea < ApplicationRecord
    has_and_belongs_to_many :property_values, class_name: 'Erp::OrthoK::PropertyValue', :join_table => 'erp_ortho_k_careas_pvalues'

    AREA_SIDE = 'area_side'
    AREA_CENTRAL = 'area_central'

    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      and_conds = []

      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end

      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end

      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?

      return query
    end

    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      end

      return query
    end

    # data for dataselect ajax
    def self.dataselect(keyword='', params='')
      query = self.all

      if keyword.present?
        keyword = keyword.strip.downcase
        query = query.where('LOWER(name) LIKE ?', "%#{keyword}%")
      end

      query = query.limit(8).map{|ca| {value: ca.id, text: ca.name} }
    end

    # data for dataselect ajax
    def self.area_dataselect(params=nil)
      [
        {text: 'Vùng trung tâm', value: self::AREA_CENTRAL},
        {text: 'Vùng rìa', value: self::AREA_SIDE},
      ]
    end
  end
end
