Erp::Products::Product.class_eval do
  has_many :transfer_details, class_name: 'Erp::StockTransfers::TransferDetail'

  # get diameter value
  def get_value(property)
    return nil if !property.present?

    if self.cache_properties.present?
      cache = JSON.parse(self.cache_properties)
      return ((cache[property.id.to_s].present? and cache[property.id.to_s][1].present?) ? cache[property.id.to_s][1] : nil)
    end
  end

  # get diameter
  def get_diameter
    self.get_value(Erp::Products::Property.getByName(Erp::Products::Property::NAME_DUONG_KINH))
  end

  # get import report
  def self.import_report(params)
    result = []

    Erp::StockTransfers::TransferDetail.joins(:transfer)
      .where(erp_stock_transfers_transfers: {status: Erp::StockTransfers::Transfer::STATUS_DELIVERED}).limit(10)
      .each do |td|
      result << {
        record_date: td.transfer.created_at,
        voucher_date: td.transfer.received_at,
        voucher_code: td.transfer.code,
        product_code: td.product_code,
        diameter: [10.6,11.6].to_a.sample, # @todo
        category: td.product.category_name,
        product_name: td.product_name,
        quantity: td.quantity,
        description: '', #@todo
        status: '', #@todo
        warehouse: td.transfer.destination_warehouse_name,
        unit: td.product.unit_name,
      }
    end

    return result
  end

  # get export report
  def self.export_report(params)
    result = []

    Erp::StockTransfers::TransferDetail.joins(:transfer)
      .where(erp_stock_transfers_transfers: {status: Erp::StockTransfers::Transfer::STATUS_DELIVERED}).limit(10)
      .each do |td|
      result << {
        record_date: td.transfer.created_at,
        voucher_date: td.transfer.received_at,
        voucher_code: td.transfer.code,
        product_code: td.product_code,
        diameter: [10.6,11.6].to_a.sample, # @todo
        category: td.product.category_name,
        product_name: td.product_name,
        quantity: td.quantity,
        description: '', #@todo
        status: '', #@todo
        warehouse: td.transfer.source_warehouse_name,
        unit: td.product.unit_name,
      }
    end

    Erp::GiftGivens::GivenDetail.joins(:given)
      .where(erp_gift_givens_givens: {status: Erp::GiftGivens::Given::STATUS_DELIVERED}).limit(10)
      .each do |gv_detail|
      result << {
        record_date: gv_detail.given.created_at,
        voucher_date: gv_detail.given.given_date,
        voucher_code: gv_detail.given.code,
        customer_name: gv_detail.given.contact_name,
        product_code: gv_detail.product_code,
        diameter: [10.6,11.6].to_a.sample, # @todo
        category: gv_detail.product.category_name,
        product_name: gv_detail.product_name,
        quantity: gv_detail.quantity,
        description: '', #@todo
        status: '', #@todo
        warehouse: gv_detail.warehouse_name,
        unit: gv_detail.product.unit_name,
      }
    end

    return result
  end

  def self.get_stock_importing_product(params={})
    # open central settings
    setting_file = 'setting_ortho_k.conf'
    if File.file?(setting_file)
      @options = YAML.load(File.read(setting_file))
    else
      return []
    end

    query = self.where(cache_stock: 0)

    if params[:filters].present?
      filters = params[:filters]

      # category
      if filters[:categories].present?
        categories = defined?(option) ? (filters[:categories].reject { |c| c.empty? }) : []
        query = query.where(category_id: filters[:categories]) if !categories.empty?
      end

      # diameter
      if filters[:diameters].present?
        if !filters[:diameters].kind_of?(Array)
          query = query.where("erp_products_products.cache_properties LIKE '%[\"#{filters[:diameters]}\",%'")
        else
          areas = defined?(option) ? (filters[:diameters].reject { |c| c.empty? }) : []
          if !areas.empty?
            qs = []
            filters[:diameters].each do |x|
              qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
            end
            query = query.where("(#{qs.join(" OR ")})")
          end
        end
      end
    end

    # need to purchase: @options["purchase_conditions"]
    ors = []
    @options["purchase_conditions"].each do |option|
      ands = []
      ands << "erp_products_products.category_id = #{option[1]["category"]}"
      ands << "erp_products_products.cache_properties LIKE '%[\"#{option[1]["diameter"]}\",%'"

      letter_pv_ids = defined?(option) ? (option[1]["letter"].reject { |c| c.empty? }) : [-1]
      number_pv_ids = defined?(option) ? (option[1]["number"].reject { |c| c.empty? }) : [-1]

      qs = []
      letter_pv_ids.each do |x|
        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
      end
      ands << "(#{qs.join(" OR ")})"

      qs = []
      number_pv_ids.each do |x|
        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
      end
      ands << "(#{qs.join(" OR ")})"

      ors << "(#{ands.join(" AND ")})"
    end

    query = query.where(ors.join(" OR "))

    return query
  end

  # check if product is belongs to central area
  def is_in_central_area
    # open central settings
    setting_file = 'setting_ortho_k.conf'
    if File.file?(setting_file)
      @options = YAML.load(File.read(setting_file))
    else
      return false
    end

    @options["central_conditions"].each do |option|
      if self.category_id == option[1]["category"].to_i
        letter_pv_ids = defined?(option) ? (option[1]["letter"].reject { |c| c.empty? }) : [-1]
        number_pv_ids = defined?(option) ? (option[1]["number"].reject { |c| c.empty? }) : [-1]

        letter_pv_ids.each do |l|
          if self.cache_properties.include? "[\"#{l}\","
            number_pv_ids.each do |n|
              if self.cache_properties.include? "[\"#{n}\","
                return true
              end
            end
          end
        end
      end
    end

    return false
  end

  # get stock class method
  def self.get_stock(options={})
    query = self.all

    # by property value
    if options[:properties_value_ids].present?
      options[:properties_value_ids].each do |x|
        query = query.where("erp_products_products.cache_properties LIKE ?", "%[\"#{x}\",%")
      end
    end

    # categories
    if options[:categories].present?
      query = query.where(category_id: options[:categories])
    end

    # diameter
    if options[:diameters].present?
      if !options[:diameters].kind_of?(Array)
        query = query.where("erp_products_products.cache_properties LIKE '%[\"#{options[:diameters]}\",%'")
      else
        diameters = defined?(option) ? (options[:diameters].reject { |c| c.empty? }) : []
        if !diameters.empty?
          qs = []
          diameters.each do |x|
            qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
          end
          query = query.where("(#{qs.join(" OR ")})")
        end
      end
    end

    # cache
    return Erp::Products::CacheStock.get_stock(query.select('id'), {state_id: options[:states], warehouse_id: options[:warehouses]})
  end

  # get stock class method
  def self.count_stock(options={})
    query = self.all

    # categories
    if options[:categories].present?
      query = query.where(category_id: options[:categories])
    end

    # diameter
    if options[:diameters].present?
      if !options[:diameters].kind_of?(Array)
        query = query.where("erp_products_products.cache_properties LIKE '%[\"#{options[:diameters]}\",%'")
      else
        diameters = defined?(option) ? (options[:diameters].reject { |c| c.empty? }) : []
        if !diameters.empty?
          qs = []
          diameters.each do |x|
            qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
          end
          query = query.where("(#{qs.join(" OR ")})")
        end
      end
    end

    # cache
    query = Erp::Products::CacheStock.filter(query.select('id'), {warehouse_id: options[:warehouses], state_id: options[:states]})

    if options[:stock_operator].present?
      query = query.where("erp_products_cache_stocks.stock #{options[:stock_operator]}")
    end

    return query.distinct.count(:product_id)
  end
end
