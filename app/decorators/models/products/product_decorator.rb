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

  # get diameter value
  def get_properties_value(property)
    return nil if !property.present?

    if self.cache_properties.present?
      cache = JSON.parse(self.cache_properties)
      return ((cache[property.id.to_s].present? and cache[property.id.to_s][1].present?) ? cache[property.id.to_s][0] : nil)
    end
  end

  # get diameter
  def get_diameter
    self.get_value(Erp::Products::Property.getByName(Erp::Products::Property::NAME_DUONG_KINH))
  end

  # get diameter
  def get_diameter_properties_value
    self.get_properties_value(Erp::Products::Property.getByName(Erp::Products::Property::NAME_DUONG_KINH))
  end

  # get import report
  def self.import_export_report(params={})
    result = []

    total = {
      quantity: 0
    }

    # Qdelivery: Có Chứng Từ
    query = Erp::Qdeliveries::DeliveryDetail.joins(:delivery, :order_detail => :product)
            .where.not(order_detail_id: nil)
            .where(erp_qdeliveries_deliveries: {status: Erp::Qdeliveries::Delivery::STATUS_DELIVERED})

    if params[:from_date].present?
      query = query.where(erp_qdeliveries_deliveries: {'date >= ?': params[:from_date].to_date.beginning_of_day})
    end

    if params[:to_date].present?
      query = query.where(erp_qdeliveries_deliveries: {'date <= ?': params[:to_date].to_date.end_of_day})
    end

    if params[:category_id].present?
      query = query.where(erp_products_products: {category_id: params[:category_id]})
    end

    if params[:warehouse_id].present?
      query = query.where(warehouse_id: params[:warehouse_id])
    end

    if params[:state_id].present?
      query = query.where(state_id: params[:state_id])
    end

    query.limit(5).each do |delivery_detail|
      if [Erp::Qdeliveries::Delivery::TYPE_WAREHOUSE_EXPORT, Erp::Qdeliveries::Delivery::TYPE_MANUFACTURER_EXPORT].include?(delivery_detail.delivery.delivery_type)
        qty = -delivery_detail.quantity
      else
        qty = +delivery_detail.quantity
      end

      result << {
        record_date: delivery_detail.delivery.created_at,
        voucher_date: delivery_detail.delivery.date,
        voucher_code: delivery_detail.delivery.code,
        customer_code: delivery_detail.delivery.customer.code,
        customer_name: delivery_detail.delivery.customer_name,
        supplier_code: delivery_detail.delivery.supplier.code,
        supplier_name: delivery_detail.delivery.supplier_name,
        product_code: delivery_detail.product_code,
        diameter: delivery_detail.order_detail.product.get_diameter,
        category: delivery_detail.order_detail.product.category_name,
        product_name: delivery_detail.product_name,
        quantity: qty,
        description: delivery_detail.note,
        state: delivery_detail.state_name,
        warehouse: delivery_detail.warehouse_name,
        unit: delivery_detail.order_detail.product.unit_name
      }
      total[:quantity] += qty
    end

    # Qdelivery: Không Chứng Từ
    query = Erp::Qdeliveries::DeliveryDetail.joins(:delivery, :product)
            .where(order_detail_id: nil)
            .where(erp_qdeliveries_deliveries: {status: Erp::Qdeliveries::Delivery::STATUS_DELIVERED})

    if params[:from_date].present?
      query = query.where(erp_qdeliveries_deliveries: {'date >= ?': params[:from_date].to_date.beginning_of_day})
    end

    if params[:to_date].present?
      query = query.where(erp_qdeliveries_deliveries: {'date <= ?': params[:to_date].to_date.end_of_day})
    end

    if params[:category_id].present?
      query = query.where(erp_products_products: {category_id: params[:category_id]})
    end

    if params[:warehouse_id].present?
      query = query.where(warehouse_id: params[:warehouse_id])
    end

    if params[:state_id].present?
      query = query.where(state_id: params[:state_id])
    end

    query.limit(5).each do |delivery_detail|
      if [Erp::Qdeliveries::Delivery::TYPE_WAREHOUSE_EXPORT, Erp::Qdeliveries::Delivery::TYPE_MANUFACTURER_EXPORT].include?(delivery_detail.delivery.delivery_type)
        qty = -delivery_detail.quantity
      else
        qty = +delivery_detail.quantity
      end

      result << {
        record_date: delivery_detail.delivery.created_at,
        voucher_date: delivery_detail.delivery.date,
        voucher_code: delivery_detail.delivery.code,
        customer_code: delivery_detail.delivery.customer.present? ? delivery_detail.delivery.customer.code : nil,
        customer_name: delivery_detail.delivery.customer.present? ? delivery_detail.delivery.customer_name : nil,
        supplier_code: delivery_detail.delivery.supplier.present? ? delivery_detail.delivery.supplier.code : nil,
        supplier_name: delivery_detail.delivery.supplier.present? ? delivery_detail.delivery.supplier_name : nil,
        product_code: delivery_detail.product_code,
        diameter: delivery_detail.product.get_diameter,
        category: delivery_detail.product.category_name,
        product_name: delivery_detail.product_name,
        quantity: qty,
        description: delivery_detail.delivery.note,
        state: delivery_detail.state_name,
        warehouse: delivery_detail.warehouse_name,
        unit: delivery_detail.product.unit_name,
      }
      total[:quantity] += qty
    end

    # Transfer: Kho Chuyển Đến /Kho Đích
    Erp::StockTransfers::TransferDetail.joins(:transfer)
    .where(erp_stock_transfers_transfers: {status: Erp::StockTransfers::Transfer::STATUS_DELIVERED}).limit(2)
    .each do |transfer_detail|
      qty = +transfer_detail.quantity
      result << {
        record_date: transfer_detail.transfer.created_at,
        voucher_date: transfer_detail.transfer.received_at,
        voucher_code: transfer_detail.transfer.code,
        product_code: transfer_detail.product_code,
        diameter: transfer_detail.product.get_diameter,
        category: transfer_detail.product.category_name,
        product_name: transfer_detail.product_name,
        quantity: qty,
        description: transfer_detail.transfer.note,
        status: transfer_detail.state_name,
        warehouse: transfer_detail.transfer.destination_warehouse_name,
        unit: transfer_detail.product.unit_name,
      }
      total[:quantity] += qty
    end

    # Transfer: Kho Chuyển Đi /Kho Nguồn
    Erp::StockTransfers::TransferDetail.joins(:transfer)
    .where(erp_stock_transfers_transfers: {status: Erp::StockTransfers::Transfer::STATUS_DELIVERED}).limit(2)
    .each do |transfer_detail|
      qty = -transfer_detail.quantity
      result << {
        record_date: transfer_detail.transfer.created_at,
        voucher_date: transfer_detail.transfer.received_at,
        voucher_code: transfer_detail.transfer.code,
        product_code: transfer_detail.product_code,
        diameter: transfer_detail.product.get_diameter,
        category: transfer_detail.product.category_name,
        product_name: transfer_detail.product_name,
        quantity: qty,
        description: transfer_detail.transfer.note,
        status: transfer_detail.state_name,
        warehouse: transfer_detail.transfer.source_warehouse_name,
        unit: transfer_detail.product.unit_name,
      }
      total[:quantity] += qty
    end

    # Gift Given /Tặng Quà
    Erp::GiftGivens::GivenDetail.joins(:given)
    .where(erp_gift_givens_givens: {status: Erp::GiftGivens::Given::STATUS_DELIVERED}).limit(5)
    .each do |gv_detail|
      qty = -gv_detail.quantity
      result << {
        record_date: gv_detail.given.created_at,
        voucher_date: gv_detail.given.given_date,
        voucher_code: gv_detail.given.code,
        customer_code: gv_detail.given.contact.code,
        customer_name: gv_detail.given.contact_name,
        product_code: gv_detail.product_code,
        diameter: gv_detail.product.get_diameter,
        category: gv_detail.product.category_name,
        product_name: gv_detail.product_name,
        quantity: qty,
        description: '', #@todo
        status: gv_detail.state_name,
        warehouse: gv_detail.warehouse_name,
        unit: gv_detail.product.unit_name
      }
      total[:quantity] += qty
    end

    # Consignment: Hàng ký gửi cho mượn
    Erp::Consignments::ConsignmentDetail.joins(:consignment)
    .where(erp_consignments_consignments: {status: Erp::Consignments::Consignment::CONSIGNMENT_STATUS_DELIVERED}).limit(2)
    .each do |csm_detail|
      qty = -csm_detail.quantity
      result << {
        record_date: csm_detail.consignment.created_at,
        voucher_date: csm_detail.consignment.sent_date,
        voucher_code: csm_detail.consignment.code,
        customer_code: csm_detail.consignment.contact.code,
        customer_name: csm_detail.consignment.contact.name,
        product_code: csm_detail.product.code,
        diameter: csm_detail.product.get_diameter,
        category: csm_detail.product.category_name,
        product_name: csm_detail.product.name,
        quantity: qty,
        description: '', #@todo
        #status: csm_detail.state_name,
        warehouse: csm_detail.consignment.warehouse_name,
        unit: csm_detail.product.unit_name
      }
      total[:quantity] += qty
    end

    # Consignment: Hàng ký gửi trả lại
    Erp::Consignments::ReturnDetail.joins(:cs_return)
    .where(erp_consignments_cs_returns: {status: Erp::Consignments::CsReturn::CS_RETURN_STATUS_DELIVERED}).limit(5)
    .each do |return_detail|
      qty = +return_detail.quantity
      result << {
        record_date: return_detail.cs_return.created_at,
        voucher_date: return_detail.cs_return.return_date,
        voucher_code: return_detail.cs_return.code,
        customer_code: return_detail.cs_return.contact.code,
        customer_name: return_detail.cs_return.contact_name,
        product_code: return_detail.consignment_detail.product.code,
        diameter: return_detail.consignment_detail.product.get_diameter,
        category: return_detail.consignment_detail.product.category_name,
        product_name: return_detail.consignment_detail.product.name,
        quantity: qty,
        description: return_detail.cs_return.note,
        #status: return_detail.state_name,
        warehouse: return_detail.cs_return.warehouse_name,
        unit: return_detail.consignment_detail.product.unit_name
      }
      total[:quantity] += qty
    end

    # Damage Record: Hàng xuất hủy
    Erp::Products::DamageRecordDetail.joins(:damage_record)
    .where(erp_products_damage_records: {status: Erp::Products::DamageRecord::STATUS_DONE}).limit(2)
    .each do |damage_record_detail|
      qty = -damage_record_detail.quantity
      result << {
        record_date: damage_record_detail.damage_record.created_at,
        voucher_date: damage_record_detail.damage_record.date,
        voucher_code: damage_record_detail.damage_record.code,
        product_code: damage_record_detail.product_code,
        diameter: damage_record_detail.product.get_diameter,
        category: damage_record_detail.product.category_name,
        product_name: damage_record_detail.product_name,
        quantity: qty,
        description: damage_record_detail.damage_record.description,
        status: damage_record_detail.state_name,
        warehouse: damage_record_detail.damage_record.warehouse_name,
        unit: damage_record_detail.product.unit_name
      }
      total[:quantity] += qty
    end

    # Stock check
    Erp::Products::StockCheckDetail.joins(:stock_check)
    .where(erp_products_stock_checks: {status: Erp::Products::StockCheck::STOCK_CHECK_STATUS_DONE}).limit(2)
    .each do |stock_check_detail|
      qty = stock_check_detail.quantity
      result << {
        record_date: stock_check_detail.stock_check.created_at,
        voucher_date: stock_check_detail.stock_check.adjustment_date,
        voucher_code: stock_check_detail.stock_check.code,
        product_code: stock_check_detail.product_code,
        diameter: stock_check_detail.product.get_diameter,
        category: stock_check_detail.product.category_name,
        product_name: stock_check_detail.product_name,
        quantity: qty,
        description: stock_check_detail.stock_check.description,
        status: stock_check_detail.state_name,
        warehouse: stock_check_detail.stock_check.warehouse_name,
        unit: stock_check_detail.product.unit_name
      }
      total[:quantity] += qty
    end

    return {
      data: result,
      total: total,
    }
  end

  def self.orthok_filters(params={})
    query = self.all

    if params[:filters].present?

      filters = params[:filters]

      # category
      if filters[:categories].present?
        categories = (filters[:categories].is_a?(Array) ? (filters[:categories].reject { |c| c.empty? }) : [filters[:categories]])
        query = query.where(category_id: categories) if !categories.empty?
      end

      # properties_values ORS
      if filters[:properties_values].present?
        properties_values = (filters[:properties_values].is_a?(Array) ? (filters[:properties_values].reject { |c| c.empty? }) : [filters[:properties_values]])
        ors = []
        properties_values.each do |pv_id|
          ors << "erp_products_products.cache_properties LIKE '%[\"#{pv_id}\",%'"
        end
        query = query.where(ors.join(' OR ')) if !ors.empty?
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

    return query
  end

  def self.get_stock_importing_product(params={})
    # open central settings
    setting_file = 'setting_ortho_k.conf'
    if File.file?(setting_file)
      @options = YAML.load(File.read(setting_file))
    else
      return []
    end

    # filter from frontend
    query = self.orthok_filters(params)

    # only in-stock products
    # query = query.where(cache_stock: 0)

    ## need to purchase: @options["purchase_conditions"]
    #ors = []
    #@options["purchase_conditions"].each do |option|
    #
    #  ands = []
    #  ands << "erp_products_products.category_id = #{option[1]["category"]}"
    #  ands << "erp_products_products.cache_properties LIKE '%[\"#{option[1]["diameter"]}\",%'"
    #
    #  letter_pv_ids = defined?(option) ? (option[1]["letter"].reject { |c| c.empty? }) : [-1]
    #  number_pv_ids = defined?(option) ? (option[1]["number"].reject { |c| c.empty? }) : [-1]
    #
    #  qs = []
    #  letter_pv_ids.each do |x|
    #    qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
    #  end
    #  ands << "(#{qs.join(" OR ")})" if !qs.empty?
    #
    #  qs = []
    #  number_pv_ids.each do |x|
    #    qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
    #  end
    #  ands << "(#{qs.join(" OR ")})" if !qs.empty?
    #
    #  ors << "(#{ands.join(" AND ")})"
    #end

    query = self.all.limit(20)#where(ors.join(" OR "))

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

  def self.delivery_report(params={})
    # filter from frontend
    query = self.orthok_filters(params)

    return query
  end

end
