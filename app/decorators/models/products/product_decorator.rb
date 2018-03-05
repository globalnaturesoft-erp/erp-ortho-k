Erp::Products::Product.class_eval do
  has_many :transfer_details, class_name: 'Erp::StockTransfers::TransferDetail'

  after_save :update_cache_diameter

  def get_default_name
    if !name.present?
      "#{self.get_letter}#{self.get_number.to_s.rjust(2, '0')}-#{self.get_diameter}-#{self.category_name}"
    else
      name
    end
  end

  def set_default_name
    if !name.present?
      self.name = self.get_default_name
      self.save
    end
  end

  def set_default_code
    if !code.present?
      self.code = "#{self.get_letter}#{self.get_number.to_s.rjust(2, '0')}"
      self.save
    end
  end

  def update_cache_diameter
    update_column(:cache_diameter, self.get_diameter)
  end

  # get diameter value
  def get_value(property)
    return nil if !property.present?

    if self.cache_properties.present?
      cache = JSON.parse(self.cache_properties)
      return ((cache[property.id.to_s].present? and cache[property.id.to_s][1].present?) ? cache[property.id.to_s][1] : nil)
    end
  end

  # get diameter value
  def get_pvid(property)
    return nil if !property.present?

    if self.cache_properties.present?
      cache = JSON.parse(self.cache_properties)
      return ((cache[property.id.to_s].present? and cache[property.id.to_s][0].present?) ? cache[property.id.to_s][0] : nil)
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
  def get_diameter_id
    self.get_pvid(Erp::Products::Property.getByName(Erp::Products::Property::NAME_DUONG_KINH))
  end

  # get diameter
  def get_letter
    self.get_value(Erp::Products::Property.getByName(Erp::Products::Property::NAME_CHU))
  end

  # get diameter
  def get_number
    self.get_value(Erp::Products::Property.getByName(Erp::Products::Property::NAME_SO))
  end

  # get diameter
  def get_diameter_properties_value
    self.get_properties_value(Erp::Products::Property.getByName(Erp::Products::Property::NAME_DUONG_KINH))
  end

  # class const - XNK (import export report)
  TYPE_SALES_EXPORT = 'sales_export'
  TYPE_SALES_IMPORT = 'sales_import'
  TYPE_PURCHASE_EXPORT = 'purchase_export'
  TYPE_PURCHASE_IMPORT = 'purchase_import'
  TYPE_CUSTOM_EXPORT = 'custom_export'
  TYPE_CUSTOM_IMPORT = 'custom_import'
  TYPE_STOCK_TRANSFER = 'stock_transfer'
  TYPE_GIFT_GIVEN = 'gift_given'
  TYPE_CONSIGNMENT = 'consignment'
  TYPE_CS_RETURN = 'cs_return'
  TYPE_DAMAGE_RECORD = 'damage_record'
  TYPE_STOCK_CHECK = 'stock_check'
  TYPE_STATE_CHECK = 'state_check'

  SORT_BY_RECORD_DATE = 'record_date'
  SORT_BY_VOUCHER_DATE = 'voucher_date'

  ORDER_BY_DESC = 'desc'
  ORDER_BY_ASC = 'asc'

  GROUPED_BY_DEFAULT = 'grouped_by_default'
  GROUPED_BY_CUSTOMER = 'grouped_by_customer'
  GROUPED_BY_PRODUCT_CODE = 'grouped_by_product_code'
  GROUPED_BY_PRODUCT_CATEGORY = 'grouped_by_product_category'

  def self.get_import_export_type_options()
    [
      {text: I18n.t('sales_export'), value: Erp::Products::Product::TYPE_SALES_EXPORT},
      {text: I18n.t('sales_import'), value: Erp::Products::Product::TYPE_SALES_IMPORT},
      {text: I18n.t('purchase_export'), value: Erp::Products::Product::TYPE_PURCHASE_EXPORT},
      {text: I18n.t('purchase_import'), value: Erp::Products::Product::TYPE_PURCHASE_IMPORT},
      {text: I18n.t('custom_export'), value: Erp::Products::Product::TYPE_CUSTOM_EXPORT},
      {text: I18n.t('custom_import'), value: Erp::Products::Product::TYPE_CUSTOM_IMPORT},
      {text: I18n.t('stock_transfer'), value: Erp::Products::Product::TYPE_STOCK_TRANSFER},
      {text: I18n.t('gift_given'), value: Erp::Products::Product::TYPE_GIFT_GIVEN},
      {text: I18n.t('consignment'), value: Erp::Products::Product::TYPE_CONSIGNMENT},
      {text: I18n.t('cs_return'), value: Erp::Products::Product::TYPE_CS_RETURN},
      {text: I18n.t('damage_record'), value: Erp::Products::Product::TYPE_DAMAGE_RECORD},
      {text: I18n.t('stock_check'), value: Erp::Products::Product::TYPE_STOCK_CHECK},
      {text: I18n.t('state_check'), value: Erp::Products::Product::TYPE_STATE_CHECK}
    ]
  end

  def self.sort_by_dates()
    [
      {
        text: I18n.t('erp.ortho_k.backend.products.import_export_report.record_date'),
        value: Erp::Products::Product::SORT_BY_RECORD_DATE
      },
      {
        text: I18n.t('erp.ortho_k.backend.products.import_export_report.voucher_date'),
        value: Erp::Products::Product::SORT_BY_VOUCHER_DATE
      }
    ]
  end

  def self.get_order_direction()
    [
      {text: I18n.t('descending'), value: Erp::Products::Product::ORDER_BY_DESC},
      {text: I18n.t('ascending'), value: Erp::Products::Product::ORDER_BY_ASC}
    ]
  end

  def self.get_grouped_bys()
    [
      {
        text: I18n.t('default'),
        value: Erp::Products::Product::GROUPED_BY_DEFAULT
      },
      {
        text: I18n.t('erp.ortho_k.backend.products.import_export_report.customer'),
        value: Erp::Products::Product::GROUPED_BY_CUSTOMER
      },
      {
        text: I18n.t('erp.ortho_k.backend.products.import_export_report.product_code'),
        value: Erp::Products::Product::GROUPED_BY_PRODUCT_CODE
      },
      {
        text: I18n.t('erp.ortho_k.backend.products.import_export_report.category'),
        value: Erp::Products::Product::GROUPED_BY_PRODUCT_CATEGORY
      },
    ]
  end

  # get import report
  def import_export_report(params={})
    return Erp::Products::Product.import_export_report(params.merge({product_id: self.id}))
  end

  # group import export
  def self.group_import_export(params={}, limit=nil)
    rows = self.import_export_report(params, limit)[:data]

    group_value = :record_date
    group_text = :record_date
    sort_value = :record_date

    # Grouped by
    if params[:group_by] == Erp::Products::Product::GROUPED_BY_DEFAULT
      group_value = :record_date
      group_text = :record_date
    end

    if params[:group_by] == Erp::Products::Product::GROUPED_BY_CUSTOMER
      group_value = :customer_code
      group_text = :customer_name
    end

    if params[:group_by] == Erp::Products::Product::GROUPED_BY_PRODUCT_CODE
      group_value = :product_code
      group_text = :product_code
    end

    if params[:group_by] == Erp::Products::Product::GROUPED_BY_PRODUCT_CATEGORY
      group_value = :category
      group_text = :category
    end

    # Sort by
    if params[:sort_by] == Erp::Products::Product::SORT_BY_RECORD_DATE
      sort_value = :record_date
    end

    if params[:sort_by] == Erp::Products::Product::SORT_BY_VOUCHER_DATE
      sort_value = :voucher_date
    end

    rows = rows.sort_by! {|a| a[group_value].to_s}
    rows.each_with_index do |row, index|
      rows[index][group_value] = nil if !row[group_value].present?
    end
    # grouping
    i_code = -1
    grouped_rows = []
    item = nil
    rows.each_with_index do |row, index|

      # finish a group
      if i_code != row[group_value] and !item.nil?
        # sorts rows
        if params[:order_by] == Erp::Products::Product::ORDER_BY_ASC
          item[:rows] = item[:rows].sort_by! {|a| a[sort_value].to_s}
        elsif params[:order_by] == Erp::Products::Product::ORDER_BY_DESC
          item[:rows] = item[:rows].sort_by! {|a| a[sort_value].to_s}.reverse!
        end

        # quantity
        item[:quantity] = (item[:rows].map {|i| i[:quantity].to_i}).sum

        # purchase_tax_amount
        item[:purchase_tax_amount] = (item[:rows].map {|i| i[:purchase_tax_amount].to_f}).sum

        # purchase_total_amount
        item[:purchase_total_amount] = (item[:rows].map {|i| i[:purchase_total_amount].to_f}).sum

        # sales_tax_amount
        item[:sales_tax_amount] = (item[:rows].map {|i| i[:sales_tax_amount].to_f}).sum

        # sales_discount
        item[:sales_discount] = (item[:rows].map {|i| i[:sales_discount].to_f}).sum

        # sales_total_amount
        item[:sales_total_amount] = (item[:rows].map {|i| i[:sales_total_amount].to_f}).sum

        grouped_rows << item.clone
      end

      if i_code != row[group_value]
        # new group
        item = {}
        item[:group_name] = row[group_text].present? ? row[group_text] : I18n.t('erp.ortho_k.backend.products.import_export_report.others')
        item[:group_sort_code] = row[group_text].present? ? row[group_text] : 'zzz'
        item[:rows] = [row]
      else
        item[:rows] << row
      end

      # finish group
      if !item.nil? and rows.count == (index + 1)
        # sorts rows
        if params[:order_by] == Erp::Products::Product::ORDER_BY_ASC
          item[:rows] = item[:rows].sort_by! {|a| a[sort_value].to_s}
        elsif params[:order_by] == Erp::Products::Product::ORDER_BY_DESC
          item[:rows] = item[:rows].sort_by! {|a| a[sort_value].to_s}.reverse!
        end

        # quantity
        item[:quantity] = (item[:rows].map {|i| i[:quantity].to_i}).sum

        # purchase_tax_amount
        item[:purchase_tax_amount] = (item[:rows].map {|i| i[:purchase_tax_amount].to_f}).sum

        # purchase_total_amount
        item[:purchase_total_amount] = (item[:rows].map {|i| i[:purchase_total_amount].to_f}).sum

        # sales_tax_amount
        item[:sales_tax_amount] = (item[:rows].map {|i| i[:sales_tax_amount].to_f}).sum

        # sales_discount
        item[:sales_discount] = (item[:rows].map {|i| i[:sales_discount].to_f}).sum

        # sales_total_amount
        item[:sales_total_amount] = (item[:rows].map {|i| i[:sales_total_amount].to_f}).sum

        grouped_rows << item.clone
      end

      # loop
      i_code = row[group_value]
    end

    totals = {}
    totals[:quantity] = (grouped_rows.map {|i| i[:quantity]}).sum
    totals[:purchase_tax_amount] = (grouped_rows.map {|i| i[:purchase_tax_amount]}).sum
    totals[:purchase_total_amount] = (grouped_rows.map {|i| i[:purchase_total_amount]}).sum
    totals[:sales_tax_amount] = (grouped_rows.map {|i| i[:sales_tax_amount]}).sum
    totals[:sales_discount] = (grouped_rows.map {|i| i[:sales_discount]}).sum
    totals[:sales_total_amount] = (grouped_rows.map {|i| i[:sales_total_amount]}).sum

    return {
      groups: grouped_rows.sort_by! {|a| a[:group_sort_code].to_s},
      totals: totals,
    }
  end

  # get import report
  def self.import_export_report(params={}, limit=nil)
    result = []

    total = {
      quantity: 0,
      purchase_tax_amount: 0,
      purchase_total_amount: 0,
      sales_tax_amount: 0,
      sales_discount: 0,
      sales_total_amount: 0
    }

    # Qdelivery: Có Chứng Từ
    query = Erp::Qdeliveries::DeliveryDetail.joins(:delivery, :order_detail => :product)
            .where.not(order_detail_id: nil)
            .where(erp_qdeliveries_deliveries: {status: Erp::Qdeliveries::Delivery::STATUS_DELIVERED})

    if params[:product_id].present?
      query = query.where(erp_orders_order_details: {product_id: params[:product_id]})
    end

    if params[:from_date].present?
      query = query.where('erp_qdeliveries_deliveries.date >= ?', params[:from_date].to_date.beginning_of_day)
    end

    if params[:to_date].present?
      query = query.where('erp_qdeliveries_deliveries.date <= ?', params[:to_date].to_date.end_of_day)
    end

    if params[:period_id].present?
      query = query.where('erp_qdeliveries_deliveries.date >= ? AND erp_qdeliveries_deliveries.date <= ?',
        Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
				Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
    end

    if params[:category_id].present?
      query = query.where(erp_products_products: {category_id: params[:category_id]})
    end

    if params[:customer_id].present?
      query = query.where(erp_qdeliveries_deliveries: {customer_id: params[:customer_id]})
    end

    if params[:supplier_id].present?
      query = query.where(erp_qdeliveries_deliveries: {supplier_id: params[:supplier_id]})
    end

    if params[:warehouse_id].present?
      query = query.where(warehouse_id: params[:warehouse_id])
    end

    if params[:state_id].present?
      query = query.where(state_id: params[:state_id])
    end

    if params[:types].present?
      query = query.where(erp_qdeliveries_deliveries: {delivery_type: params[:types]})
    end

    query.limit(limit).each do |delivery_detail|
      if [Erp::Qdeliveries::Delivery::TYPE_SALES_EXPORT, Erp::Qdeliveries::Delivery::TYPE_PURCHASE_EXPORT].include?(delivery_detail.delivery.delivery_type)
        qty = -delivery_detail.quantity
        qty_export = delivery_detail.quantity
        source_warehouse = delivery_detail.warehouse_name
      else
        qty = +delivery_detail.quantity
        qty_import = delivery_detail.quantity
        destination_warehouse = delivery_detail.warehouse_name
      end

      if delivery_detail.order_detail.order.purchase?
        purchase_price = delivery_detail.order_detail.price
        purchase_tax_amount = delivery_detail.order_detail.tax_amount
        purchase_total_amount = delivery_detail.order_detail.subtotal
      elsif delivery_detail.order_detail.order.sales?
        sales_price = delivery_detail.order_detail.price
        sales_tax_amount = delivery_detail.order_detail.tax_amount
        sales_discount = delivery_detail.order_detail.discount_amount
        sales_total_amount = delivery_detail.order_detail.subtotal
      end

      result << {
        record_type: delivery_detail.delivery.delivery_type,
        record_date: delivery_detail.delivery.created_at,
        voucher_date: delivery_detail.delivery.date,
        voucher_code: delivery_detail.delivery.code,
        customer_code: delivery_detail.delivery.customer_code,
        customer_name: delivery_detail.delivery.customer_name,
        supplier_code: delivery_detail.delivery.supplier_code,
        supplier_name: delivery_detail.delivery.supplier_name,
        product_code: delivery_detail.product_code,
        diameter: delivery_detail.order_detail.product.get_diameter,
        category: delivery_detail.order_detail.product.category_name,
        product_name: delivery_detail.product_name,
        quantity: qty,
        qty_import: qty_import,
        qty_export: qty_export,
        description: delivery_detail.note,
        state: delivery_detail.state_name,
        source_warehouse: source_warehouse,
        destination_warehouse: destination_warehouse,
        warehouse: delivery_detail.warehouse_name,
        unit: delivery_detail.order_detail.product.unit_name,
        purchase_price: purchase_price.present? ? purchase_price : '',
        purchase_tax_amount: purchase_tax_amount.present? ? purchase_tax_amount : '',
        purchase_total_amount: purchase_total_amount.present? ? purchase_total_amount : '',
        sales_price: sales_price.present? ? sales_price : '',
        sales_tax_amount: sales_tax_amount.present? ? sales_tax_amount : '',
        sales_discount: sales_discount.present? ? sales_discount : '',
        sales_total_amount: sales_total_amount.present? ? sales_total_amount : ''
      }
      total[:quantity] += qty
      total[:purchase_tax_amount] += purchase_tax_amount.to_f
      total[:purchase_total_amount] += purchase_total_amount.to_f
      total[:sales_tax_amount] += sales_tax_amount.to_f
      total[:sales_discount] += sales_discount.to_f
      total[:sales_total_amount] += sales_total_amount.to_f
    end

    # Qdelivery: Không Chứng Từ
    query = Erp::Qdeliveries::DeliveryDetail.joins(:delivery, :product)
            .where(order_detail_id: nil)
            .where(erp_qdeliveries_deliveries: {status: Erp::Qdeliveries::Delivery::STATUS_DELIVERED})

    if params[:product_id].present?
      query = query.where(product_id: params[:product_id])
    end

    if params[:from_date].present?
      query = query.where('erp_qdeliveries_deliveries.date >= ?', params[:from_date].to_date.beginning_of_day)
    end

    if params[:to_date].present?
      query = query.where('erp_qdeliveries_deliveries.date <= ?', params[:to_date].to_date.end_of_day)
    end

    if params[:period_id].present?
      query = query.where('erp_qdeliveries_deliveries.date >= ? AND erp_qdeliveries_deliveries.date <= ?',
        Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
				Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
    end

    if params[:category_id].present?
      query = query.where(erp_products_products: {category_id: params[:category_id]})
    end

    if params[:customer_id].present?
      query = query.where(erp_qdeliveries_deliveries: {customer_id: params[:customer_id]})
    end

    if params[:supplier_id].present?
      query = query.where(erp_qdeliveries_deliveries: {supplier_id: params[:supplier_id]})
    end

    if params[:warehouse_id].present?
      query = query.where(warehouse_id: params[:warehouse_id])
    end

    if params[:state_id].present?
      query = query.where(state_id: params[:state_id])
    end

    if params[:types].present?
      query = query.where(erp_qdeliveries_deliveries: {delivery_type: params[:types]})
    end

    query.limit(limit).each do |delivery_detail|
      if [Erp::Qdeliveries::Delivery::TYPE_SALES_EXPORT, Erp::Qdeliveries::Delivery::TYPE_PURCHASE_EXPORT].include?(delivery_detail.delivery.delivery_type)
        qty = -delivery_detail.quantity
        qty_export = delivery_detail.quantity
        source_warehouse = delivery_detail.warehouse_name
      else
        qty = +delivery_detail.quantity
        qty_import = delivery_detail.quantity
        destination_warehouse = delivery_detail.warehouse_name
      end

      result << {
        record_type: delivery_detail.delivery.delivery_type,
        record_date: delivery_detail.delivery.created_at,
        voucher_date: delivery_detail.delivery.date,
        voucher_code: delivery_detail.delivery.code,
        customer_code: delivery_detail.delivery.customer_code,
        customer_name: delivery_detail.delivery.customer_name,
        supplier_code: delivery_detail.delivery.supplier_code,
        supplier_name: delivery_detail.delivery.supplier_name,
        product_code: delivery_detail.product_code,
        diameter: delivery_detail.product.get_diameter,
        category: delivery_detail.product.category_name,
        product_name: delivery_detail.product_name,
        quantity: qty,
        qty_import: qty_import,
        qty_export: qty_export,
        description: delivery_detail.delivery.note,
        state: delivery_detail.state_name,
        source_warehouse: source_warehouse,
        destination_warehouse: destination_warehouse,
        warehouse: delivery_detail.warehouse_name,
        unit: delivery_detail.product.unit_name
      }
      total[:quantity] += qty
    end

    # @todo tạm thời không lọc lịch sử xuất nhập kho theo StockTransfer (trên chi tiết sản phẩm)
    if !(params[:not_filters].present? and params[:not_filters] == 'stock_transfer')
      if !params[:customer_id].present? and !params[:supplier_id].present?
        if params[:warehouse_id].present? or params[:source_warehouse_id].present? or params[:destination_warehouse_id].present?
          if (params[:types].present? and params[:types].include?(Erp::Products::Product::TYPE_STOCK_TRANSFER)) or params[:types].nil?
            # Transfer: Kho Chuyển Đến /Kho Đích
            query = Erp::StockTransfers::TransferDetail.joins(:transfer, :product)
                    .where(erp_stock_transfers_transfers: {status: Erp::StockTransfers::Transfer::STATUS_DELIVERED})
                    .limit(limit)

            if params[:product_id].present?
              query = query.where(product_id: params[:product_id])
            end

            if params[:from_date].present?
              query = query.where('erp_stock_transfers_transfers.received_at >= ?', params[:from_date].to_date.beginning_of_day)
            end

            if params[:to_date].present?
              query = query.where('erp_stock_transfers_transfers.received_at <= ?', params[:to_date].to_date.end_of_day)
            end

            if params[:period_id].present?
              query = query.where('erp_stock_transfers_transfers.received_at >= ? AND erp_stock_transfers_transfers.received_at <= ?',
                Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
                Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
            end

            if params[:category_id].present?
              query = query.where(erp_products_products: {category_id: params[:category_id]})
            end

            if params[:warehouse_id].present? # @todo loc theo kho dich (tuy tung truong hop ma xet them kho nguon)
              query = query.where('erp_stock_transfers_transfers.destination_warehouse_id IN (?)', params[:warehouse_id])
            end

            if params[:source_warehouse_id].present?
              query = query.where(erp_stock_transfers_transfers: {source_warehouse_id: params[:source_warehouse_id]})
            end

            if params[:destination_warehouse_id].present?
              query = query.where(erp_stock_transfers_transfers: {destination_warehouse_id: params[:destination_warehouse_id]})
            end

            if params[:state_id].present?
              query = query.where(state_id: params[:state_id])
            end

            query.each do |transfer_detail|
              qty = +transfer_detail.quantity
              qty_export = transfer_detail.quantity
              result << {
                record_type: 'stock_transfer',
                record_date: transfer_detail.transfer.created_at,
                voucher_date: transfer_detail.transfer.received_at,
                voucher_code: transfer_detail.transfer.code,
                product_code: transfer_detail.product_code,
                diameter: transfer_detail.product.get_diameter,
                category: transfer_detail.product.category_name,
                product_name: transfer_detail.product_name,
                quantity: qty,
                qty_export: qty_export,
                description: transfer_detail.transfer.note,
                state: transfer_detail.state_name,
                source_warehouse: transfer_detail.transfer.source_warehouse_name,
                destination_warehouse: transfer_detail.transfer.destination_warehouse_name,
                warehouse: transfer_detail.transfer.destination_warehouse_name,
                unit: transfer_detail.product.unit_name,
              }
              total[:quantity] += qty
            end

            # Transfer: Kho Chuyển Đi /Kho Nguồn
            query = Erp::StockTransfers::TransferDetail.joins(:transfer)
                  .where(erp_stock_transfers_transfers: {status: Erp::StockTransfers::Transfer::STATUS_DELIVERED})
                  .limit(limit)

            if params[:product_id].present?
              query = query.where(product_id: params[:product_id])
            end

            if params[:from_date].present?
              query = query.where('erp_stock_transfers_transfers.received_at >= ?', params[:from_date].to_date.beginning_of_day)
            end

            if params[:to_date].present?
              query = query.where('erp_stock_transfers_transfers.received_at <= ?', params[:to_date].to_date.end_of_day)
            end

            if params[:period_id].present?
              query = query.where('erp_stock_transfers_transfers.received_at >= ? AND erp_stock_transfers_transfers.received_at <= ?',
                Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
                Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
            end

            if params[:category_id].present?
              query = query.where(erp_products_products: {category_id: params[:category_id]})
            end

            if params[:warehouse_id].present? # @todo loc theo kho nguon (tuy tung truong hop ma xet them kho dich)
              query = query.where('erp_stock_transfers_transfers.source_warehouse_id IN (?)', params[:warehouse_id])
            end

            if params[:source_warehouse_id].present?
              query = query.where('erp_stock_transfers_transfers.source_warehouse_id = ?', params[:source_warehouse_id])
            end

            if params[:destination_warehouse_id].present?
              query = query.where('erp_stock_transfers_transfers.destination_warehouse_id = ?', params[:destination_warehouse_id])
            end

            if params[:state_id].present?
              query = query.where(state_id: params[:state_id])
            end

            query.each do |transfer_detail|
              qty = -transfer_detail.quantity
              qty_import = transfer_detail.quantity
              result << {
                record_type: 'stock_transfer',
                record_date: transfer_detail.transfer.created_at,
                voucher_date: transfer_detail.transfer.received_at,
                voucher_code: transfer_detail.transfer.code,
                product_code: transfer_detail.product_code,
                diameter: transfer_detail.product.get_diameter,
                category: transfer_detail.product.category_name,
                product_name: transfer_detail.product_name,
                quantity: qty,
                qty_import: qty_import,
                description: transfer_detail.transfer.note,
                state: transfer_detail.state_name,
                source_warehouse: transfer_detail.transfer.source_warehouse_name,
                destination_warehouse: transfer_detail.transfer.destination_warehouse_name,
                warehouse: transfer_detail.transfer.source_warehouse_name,
                unit: transfer_detail.product.unit_name,
              }
              total[:quantity] += qty
            end
          end
        end
      end
    end

    # Gift Given /Tặng Quà
    if !params[:supplier_id].present?
      if (params[:types].present? and params[:types].include?(Erp::Products::Product::TYPE_GIFT_GIVEN)) or params[:types].nil?
        query = Erp::GiftGivens::GivenDetail.joins(:given, :product)
                .where(erp_gift_givens_givens: {status: Erp::GiftGivens::Given::STATUS_DELIVERED})
                .limit(limit)

        if params[:product_id].present?
          query = query.where(product_id: params[:product_id])
        end

        if params[:from_date].present?
          query = query.where('erp_gift_givens_givens.given_date >= ?', params[:from_date].to_date.beginning_of_day)
        end

        if params[:to_date].present?
          query = query.where('erp_gift_givens_givens.given_date <= ?', params[:to_date].to_date.end_of_day)
        end

        if params[:period_id].present?
          query = query.where('erp_gift_givens_givens.given_date >= ? AND erp_gift_givens_givens.given_date <= ?',
            Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
            Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
        end

        if params[:category_id].present?
          query = query.where(erp_products_products: {category_id: params[:category_id]})
        end

        if params[:customer_id].present?
          query = query.where(erp_gift_givens_givens: {contact_id: params[:customer_id]})
        end

        if params[:warehouse_id].present?
          query = query.where(warehouse_id: params[:warehouse_id])
        end

        if params[:state_id].present?
          query = query.where(state_id: params[:state_id])
        end

        query.each do |gv_detail|
          qty = -gv_detail.quantity
          qty_export = gv_detail.quantity
          result << {
            record_type: 'gift_given',
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
            qty_export: qty_export,
            description: '', #@todo
            state: gv_detail.state_name,
            source_warehouse: gv_detail.warehouse_name,
            warehouse: gv_detail.warehouse_name,
            unit: gv_detail.product.unit_name
          }
          total[:quantity] += qty
        end
      end
    end

    # Consignment: Hàng ký gửi cho mượn
    if !params[:supplier_id].present?
      if (params[:types].present? and params[:types].include?(Erp::Products::Product::TYPE_CONSIGNMENT)) or params[:types].nil?
        query = Erp::Consignments::ConsignmentDetail.joins(:consignment, :product)
                .where(erp_consignments_consignments: {status: Erp::Consignments::Consignment::STATUS_DELIVERED})
                .limit(limit)

        if params[:product_id].present?
          query = query.where(product_id: params[:product_id])
        end

        if params[:from_date].present?
          query = query.where('erp_consignments_consignments.sent_date >= ?', params[:from_date].to_date.beginning_of_day)
        end

        if params[:to_date].present?
          query = query.where('erp_consignments_consignments.sent_date <= ?', params[:to_date].to_date.end_of_day)
        end

        if params[:period_id].present?
          query = query.where('erp_consignments_consignments.sent_date >= ? AND erp_consignments_consignments.sent_date <= ?',
            Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
            Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
        end

        if params[:category_id].present?
          query = query.where(erp_products_products: {category_id: params[:category_id]})
        end

        if params[:customer_id].present?
          query = query.where(erp_consignments_consignments: {contact_id: params[:customer_id]})
        end

        if params[:warehouse_id].present?
          query = query.where(erp_consignments_consignments: {warehouse_id: params[:warehouse_id]})
        end

        if params[:state_id].present?
          query = query.where(state_id: params[:state_id])
        end

        query.each do |csm_detail|
          qty = -csm_detail.quantity
          qty_export = csm_detail.quantity
          result << {
            record_type: 'consignment',
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
            qty_export: qty_export,
            description: '', #@todo
            state: csm_detail.state_name,
            warehouse: csm_detail.consignment.warehouse_name,
            source_warehouse: csm_detail.consignment.warehouse_name,
            unit: csm_detail.product.unit_name
          }
          total[:quantity] += qty
        end
      end
    end

    # Consignment: Hàng ký gửi trả lại
    if !params[:supplier_id].present?
      if (params[:types].present? and params[:types].include?(Erp::Products::Product::TYPE_CS_RETURN)) or params[:types].nil?
        query = Erp::Consignments::ReturnDetail.joins(:cs_return, :consignment_detail => :product)
                .where(erp_consignments_cs_returns: {status: Erp::Consignments::CsReturn::STATUS_DELIVERED})
                .limit(limit)

        if params[:product_id].present?
          query = query.where(erp_consignments_consignment_details: {product_id: params[:product_id]})
        end

        if params[:from_date].present?
          query = query.where('erp_consignments_cs_returns.return_date >= ?', params[:from_date].to_date.beginning_of_day)
        end

        if params[:to_date].present?
          query = query.where('erp_consignments_cs_returns.return_date <= ?', params[:to_date].to_date.end_of_day)
        end

        if params[:period_id].present?
          query = query.where('erp_consignments_cs_returns.return_date >= ? AND erp_consignments_cs_returns.return_date <= ?',
            Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
            Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
        end

        if params[:category_id].present?
          query = query.where(erp_products_products: {category_id: params[:category_id]})
        end

        if params[:customer_id].present?
          query = query.where(erp_consignments_cs_returns: {contact_id: params[:customer_id]})
        end

        if params[:warehouse_id].present?
          query = query.where(erp_consignments_cs_returns: {warehouse_id: params[:warehouse_id]})
        end

        if params[:state_id].present?
          query = query.where(state_id: params[:state_id])
        end

        query.each do |return_detail|
          qty = +return_detail.quantity
          qty_import = return_detail.quantity
          result << {
            record_type: 'cs_return',
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
            qty_import: qty_import,
            description: return_detail.cs_return.note,
            state: return_detail.state_name,
            warehouse: return_detail.cs_return.warehouse_name,
            destination_warehouse: return_detail.cs_return.warehouse_name,
            unit: return_detail.consignment_detail.product.unit_name
          }
          total[:quantity] += qty
        end
      end
    end

    # Damage Record: Hàng xuất hủy
    if !params[:customer_id].present? and !params[:supplier_id].present?
      if (params[:types].present? and params[:types].include?(Erp::Products::Product::TYPE_DAMAGE_RECORD)) or params[:types].nil?
        query = Erp::Products::DamageRecordDetail.joins(:damage_record, :product)
                .where(erp_products_damage_records: {status: Erp::Products::DamageRecord::STATUS_DONE})
                .limit(limit)

        if params[:product_id].present?
          query = query.where(product_id: params[:product_id])
        end

        if params[:from_date].present?
          query = query.where('erp_products_damage_records.date >= ?', params[:from_date].to_date.beginning_of_day)
        end

        if params[:to_date].present?
          query = query.where('erp_products_damage_records.date <= ?', params[:to_date].to_date.end_of_day)
        end

        if params[:period_id].present?
          query = query.where('erp_products_damage_records.date >= ? AND erp_products_damage_records.date <= ?',
            Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
            Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
        end

        if params[:category_id].present?
          query = query.where(erp_products_products: {category_id: params[:category_id]})
        end

        if params[:warehouse_id].present?
          query = query.where(erp_products_damage_records: {warehouse_id: params[:warehouse_id]})
        end

        if params[:state_id].present?
          query = query.where(state_id: params[:state_id])
        end

        query.each do |damage_record_detail|
          qty = -damage_record_detail.quantity
          qty_export = damage_record_detail.quantity
          result << {
            record_type: 'damage_record',
            record_date: damage_record_detail.damage_record.created_at,
            voucher_date: damage_record_detail.damage_record.date,
            voucher_code: damage_record_detail.damage_record.code,
            product_code: damage_record_detail.product_code,
            diameter: damage_record_detail.product.get_diameter,
            category: damage_record_detail.product.category_name,
            product_name: damage_record_detail.product_name,
            quantity: qty,
            qty_export: qty_export,
            description: damage_record_detail.damage_record.description,
            state: damage_record_detail.state_name,
            warehouse: damage_record_detail.damage_record.warehouse_name,
            source_warehouse: damage_record_detail.damage_record.warehouse_name,
            unit: damage_record_detail.product.unit_name,
            note: damage_record_detail.note
          }
          total[:quantity] += qty
        end
      end
    end

    # Stock check
    if !params[:customer_id].present? and !params[:supplier_id].present?
      if (params[:types].present? and params[:types].include?(Erp::Products::Product::TYPE_STOCK_CHECK)) or params[:types].nil?
        query = Erp::Products::StockCheckDetail.joins(:stock_check, :product)
                .where(erp_products_stock_checks: {status: Erp::Products::StockCheck::STATUS_DONE})
                .limit(limit)
                .where.not(quantity: 0)

        if params[:product_id].present?
          query = query.where(product_id: params[:product_id])
        end

        if params[:from_date].present?
          query = query.where('erp_products_stock_checks.adjustment_date >= ?', params[:from_date].to_date.beginning_of_day)
        end

        if params[:to_date].present?
          query = query.where('erp_products_stock_checks.adjustment_date <= ?', params[:to_date].to_date.end_of_day)
        end

        if params[:period_id].present?
          query = query.where('erp_products_stock_checks.adjustment_date >= ? AND erp_products_stock_checks.adjustment_date <= ?',
            Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
            Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
        end

        if params[:category_id].present?
          query = query.where(erp_products_products: {category_id: params[:category_id]})
        end

        if params[:warehouse_id].present?
          query = query.where(erp_products_stock_checks: {warehouse_id: params[:warehouse_id]})
        end

        if params[:state_id].present?
          query = query.where(state_id: params[:state_id])
        end

        query.each do |stock_check_detail|
          qty = stock_check_detail.quantity
          if qty < 0
            qty_export = stock_check_detail.quantity
            source_warehouse = stock_check_detail.stock_check.warehouse_name
          elsif qty > 0
            qty_import = stock_check_detail.quantity
            destination_warehouse = stock_check_detail.stock_check.warehouse_name
          end
          result << {
            record_type: 'stock_check',
            record_date: stock_check_detail.stock_check.created_at,
            voucher_date: stock_check_detail.stock_check.adjustment_date,
            voucher_code: stock_check_detail.stock_check.code,
            product_code: stock_check_detail.product_code,
            diameter: stock_check_detail.product.get_diameter,
            category: stock_check_detail.product.category_name,
            product_name: stock_check_detail.product_name,
            quantity: qty,
            qty_import: qty_import,
            qty_export: qty_export,
            description: stock_check_detail.stock_check.description,
            state: stock_check_detail.state_name,
            source_warehouse: source_warehouse,
            destination_warehouse: destination_warehouse,
            warehouse: stock_check_detail.stock_check.warehouse_name,
            unit: stock_check_detail.product.unit_name,
            note: stock_check_detail.note
          }
          total[:quantity] += qty
        end
      end
    end

    # State check // trạng thái
    if !params[:customer_id].present? and !params[:supplier_id].present?
      if (params[:types].present? and params[:types].include?(Erp::Products::Product::TYPE_STATE_CHECK)) or params[:types].nil?
        query = Erp::Products::StateCheckDetail.joins(:state_check, :product)
                .where(erp_products_state_checks: {status: Erp::Products::StateCheck::STATE_CHECK_STATUS_ACTIVE})
                .limit(limit)
                .where.not(quantity: 0)

        if params[:product_id].present?
          query = query.where(product_id: params[:product_id])
        end

        if params[:from_date].present?
          query = query.where('erp_products_state_checks.check_date >= ?', params[:from_date].to_date.beginning_of_day)
        end

        if params[:to_date].present?
          query = query.where('erp_products_state_checks.check_date <= ?', params[:to_date].to_date.end_of_day)
        end

        if params[:period_id].present?
          query = query.where('erp_products_state_checks.check_date >= ? AND erp_products_state_checks.check_date <= ?',
            Erp::Periods::Period.find(params[:period_id]).from_date.beginning_of_day,
            Erp::Periods::Period.find(params[:period_id]).to_date.end_of_day)
        end

        if params[:category_id].present?
          query = query.where(erp_products_products: {category_id: params[:category_id]})
        end

        if params[:warehouse_id].present?
          query = query.where(erp_products_state_checks: {warehouse_id: params[:warehouse_id]})
        end

        # Old state
        query1 = query
        if params[:state_id].present?
          query1 = query.where(old_state_id: params[:state_id])
        end

        query1.each do |state_check_detail|
          qty = - state_check_detail.quantity
          result << {
            record_type: 'state_check',
            record_date: state_check_detail.state_check.created_at,
            voucher_date: state_check_detail.state_check.check_date,
            voucher_code: state_check_detail.state_check.code,
            product_code: state_check_detail.get_product_code,
            diameter: state_check_detail.product.get_diameter,
            category: state_check_detail.product.category_name,
            product_name: state_check_detail.get_product_name,
            quantity: qty,
            description: state_check_detail.state_check.note,
            state: state_check_detail.get_old_state_name,
            warehouse: state_check_detail.state_check.warehouse_name,
            unit: state_check_detail.product.unit_name,
            note: state_check_detail.note
          }
          total[:quantity] += qty
        end

        # New state
        query2 = query
        if params[:state_id].present?
          query2 = query.where(state_id: params[:state_id])
        end

        query2.each do |state_check_detail|
          qty = state_check_detail.quantity
          result << {
            record_type: 'state_check',
            record_date: state_check_detail.state_check.created_at,
            voucher_date: state_check_detail.state_check.check_date,
            voucher_code: state_check_detail.state_check.code,
            product_code: state_check_detail.get_product_code,
            diameter: state_check_detail.product.get_diameter,
            category: state_check_detail.product.category_name,
            product_name: state_check_detail.get_product_name,
            quantity: qty,
            description: state_check_detail.state_check.note,
            state: state_check_detail.get_state_name,
            warehouse: state_check_detail.state_check.warehouse_name,
            unit: state_check_detail.product.unit_name,
            note: state_check_detail.note
          }
          total[:quantity] += qty
        end
      end
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

      # single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(erp_products_products.cache_search) LIKE ?', '%'+q+'%')
				end
			end

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
          areas = filters[:diameters].reject { |c| c.empty? }
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

  # Get products in purchase conditions area
  def self.get_in_purchase_condition_products
    # need to purchase: @options["purchase_conditions"]
    ors = []
    @options["purchase_conditions"].each do |option|
      if option[1]["category"].present?
        ands = []
        ands << "erp_products_products.category_id = #{option[1]["category"]}"
        ands << "erp_products_products.cache_properties LIKE '%[\"#{option[1]["diameter"]}\",%'"

        letter_pv_ids = defined?(option) ? (option[1]["letter"].reject { |c| c.empty? }) : [-1]
        number_pv_ids = defined?(option) ? (option[1]["number"].reject { |c| c.empty? }) : [-1]

        qs = []
        letter_pv_ids.each do |x|
          qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
        end
        ands << "(#{qs.join(" OR ")})" if !qs.empty?

        qs = []
        number_pv_ids.each do |x|
          qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
        end
        ands << "(#{qs.join(" OR ")})" if !qs.empty?

        ors << "(#{ands.join(" AND ")})"
      end
    end

    query = self.where(ors.join(" OR "))

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

    # stock conditions
    state_id = params[:state].present? ? params[:state] : nil
    warehouse_ids = params[:warehouses].present? ? params[:warehouses] : nil

    cs_ids = Erp::Products::CacheStock.select('erp_products_cache_stocks.product_id, SUM(erp_products_cache_stocks.stock) AS stock_count')
      .group('erp_products_cache_stocks.product_id')
      .where(state_id: state_id)
      .where(warehouse_id: warehouse_ids)
      .having('SUM(erp_products_cache_stocks.stock) <= ?', params[:stock_condition])
      .map(&:product_id)

    query = query.where(id: cs_ids)

    # Get in purchase conditions area
    query = query.get_in_purchase_condition_products

    return query
  end

  def self.get_in_central_area
    # open central settings
    setting_file = 'setting_ortho_k.conf'
    if File.file?(setting_file)
      @options = YAML.load(File.read(setting_file))
    else
      return []
    end

    # need to purchase: @options["purchase_conditions"]
    ors = []
    @options["central_conditions"].each do |option|

      ands = []
      ands << "erp_products_products.category_id = #{option[1]["category"]}"
      ands << "erp_products_products.cache_properties LIKE '%[\"#{option[1]["diameter"]}\",%'"

      letter_pv_ids = defined?(option) ? (option[1]["letter"].reject { |c| c.empty? }) : [-1]
      number_pv_ids = defined?(option) ? (option[1]["number"].reject { |c| c.empty? }) : [-1]

      qs = []
      letter_pv_ids.each do |x|
        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
      end
      ands << "(#{qs.join(" OR ")})" if !qs.empty?

      qs = []
      number_pv_ids.each do |x|
        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
      end
      ands << "(#{qs.join(" OR ")})" if !qs.empty?

      ors << "(#{ands.join(" AND ")})"
    end

    query = self.where(ors.join(" OR "))

    return query
  end

  def self.get_not_in_central_area
    # open central settings
    setting_file = 'setting_ortho_k.conf'
    if File.file?(setting_file)
      @options = YAML.load(File.read(setting_file))
    else
      return []
    end

    # need to purchase: @options["purchase_conditions"]
    ors = []
    @options["central_conditions"].each do |option|

      ands = []
      ands << "erp_products_products.category_id = #{option[1]["category"]}"
      ands << "erp_products_products.cache_properties LIKE '%[\"#{option[1]["diameter"]}\",%'"

      letter_pv_ids = defined?(option) ? (option[1]["letter"].reject { |c| c.empty? }) : [-1]
      number_pv_ids = defined?(option) ? (option[1]["number"].reject { |c| c.empty? }) : [-1]

      qs = []
      letter_pv_ids.each do |x|
        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
      end
      ands << "(#{qs.join(" OR ")})" if !qs.empty?

      qs = []
      number_pv_ids.each do |x|
        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
      end
      ands << "(#{qs.join(" OR ")})" if !qs.empty?

      ors << "(#{ands.join(" AND ")})"
    end

    query = self.where.not(ors.join(" OR "))

    return query
  end

  def self.get_central_area_products(params={})
    # open central settings
    setting_file = 'setting_ortho_k.conf'
    if File.file?(setting_file)
      @options = YAML.load(File.read(setting_file))
    else
      return []
    end

    # filter from frontend
    query = self.orthok_filters(params)

    # only not-in-stock products
    query = query.where(cache_stock: 0)

    # need to purchase: @options["purchase_conditions"]
    ors = []
    @options["central_conditions"].each do |option|

      ands = []
      ands << "erp_products_products.category_id = #{option[1]["category"]}"
      ands << "erp_products_products.cache_properties LIKE '%[\"#{option[1]["diameter"]}\",%'"

      letter_pv_ids = defined?(option) ? (option[1]["letter"].reject { |c| c.empty? }) : [-1]
      number_pv_ids = defined?(option) ? (option[1]["number"].reject { |c| c.empty? }) : [-1]

      qs = []
      letter_pv_ids.each do |x|
        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
      end
      ands << "(#{qs.join(" OR ")})" if !qs.empty?

      qs = []
      number_pv_ids.each do |x|
        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
      end
      ands << "(#{qs.join(" OR ")})" if !qs.empty?

      ors << "(#{ands.join(" AND ")})"
    end

    query = self.where(ors.join(" OR "))

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

    if @options["central_conditions"].present?
      @options["central_conditions"].each do |option|
        if self.category_id == option[1]["category"].to_i
          letter_pv_ids = defined?(option) ? (option[1]["letter"].reject { |c| c.empty? }) : [-1]
          number_pv_ids = defined?(option) ? (option[1]["number"].reject { |c| c.empty? }) : [-1]

          letter_pv_ids.each do |l|
            if self.cache_properties.include? "[\"#{l}\","
              number_pv_ids.each do |n|
                if self.cache_properties.include? "[\"#{n}\"," and (self.cache_properties.include? "[\"#{option[1]["diameter"].to_i}\"," or !option[1]["diameter"].present?)
                  return true
                end
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

    products = query.select('id')

    products = -1 if products.empty?

    # cache
    return Erp::Products::CacheStock.get_stock(products, {state_id: options[:states], warehouse_id: options[:warehouses]})
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

  # import init stock from file
  def self.import_init_stock(file)
    # config
    timestamp = Time.now.to_i
    xlsx = Roo::Spreadsheet.open(file)
    user = Erp::User.first
    state = Erp::Products::State.first  # Mới
    warehouse = Erp::Warehouses::Warehouse.first  # SG

    # Read excel file. sheet tabs loop
    xlsx.each_with_pagename do |name, sheet|
      cat_name = name.strip

      # Check if sheet tab is LEN
      if ["Standard","Premium","Toric","Express","SP", "SCL"].include?(cat_name)
        # Stock check
        stock_check = Erp::Products::StockCheck.new(
          creator_id: user.id,
          warehouse_id: warehouse.id,
          adjustment_date: Time.now,
          employee_id: user.id,
          status: Erp::Products::StockCheck::STATUS_DONE,
          adjustment_date: '2010-01-01'.to_date,
          description: "Nhập tồn đầu: #{cat_name}"
        )
        details = []

        # Header, first table row
        headers = sheet.row(3)

        # description
        stock_check.description = "Nhập kho ban đầu: #{cat_name}"

        headers.each_with_index do |header, index|
          if ["10.4","10.5","10.6","10.8","11","11.2","11.4","16.4"].include?(header.to_s)
            # diameter
            diameter_p = Erp::Products::Property.get_diameter
            diameter_ppv = Erp::Products::PropertiesValue.where(property_id: diameter_p.id, value: header.to_s).first

            sheet.each_row_streaming do |row|
              if !row[0].value.nil? and row[0].value != 'Ma Len' and row[index].present? and row[index].value.to_i > 0 and !["10.4","10.6","10.8","11","11.2","11.4","11.6","16.4"].include?(row[index].value.to_s)
                lns = row[0].value.scan(/\d+|\D+/)

                # quantity
                stock = row[index].value

                # letter
                letter_p = Erp::Products::Property.get_letter
                letter_ppv = Erp::Products::PropertiesValue.where(property_id: letter_p.id, value: lns[0]).first

                # number
                nn_v = lns[1]
                nn_v = nn_v.rjust(2, '0') if nn_v != '0' and nn_v != '00'
                number_p = Erp::Products::Property.get_number
                number_ppv = Erp::Products::PropertiesValue.where(property_id: number_p.id, value: nn_v).first

                if diameter_ppv.present? and letter_ppv.present? and number_ppv.present?
                  pname = "#{letter_ppv.value}#{number_ppv.value}-#{diameter_ppv.value}-#{cat_name}"

                  # Find product
                  product = Erp::Products::Product
                    .where(name: pname)
                    .first

                  # check if product exist
                  if product.present?
                    # add stock check detail
                    details << stock_check.stock_check_details.build(
                      product_id: product.id,
                      quantity: stock,
                      state_id: state.id
                    )

                    result = "SUCCESS::#{pname}: exist! checked! (#{stock})"
                  else
                    result = "ERROR::#{pname}: not exist! ignored! (#{stock})"
                  end
                else
                  result = "ERROR::#{lns}: ppvs not exist! ignored! (#{stock})"
                end

                # Logging
                puts result
                File.open("tmp/import_init_stock-#{timestamp}.log", "a+") { |f| f << "#{result}\n"}
              end
            end
          end
        end

        # Save stock check record
        puts details.count
        #self.transaction do
        #  stock_check.save
        #end
      end



      ################################################ SOFT OK LEN ###############################################
      if ["Soft OK"].include?(cat_name)
        # Stock check
        stock_check = Erp::Products::StockCheck.new(
          creator_id: user.id,
          warehouse_id: warehouse.id,
          adjustment_date: Time.now,
          employee_id: user.id,
          status: Erp::Products::StockCheck::STATUS_DONE,
          adjustment_date: '2010-01-01'.to_date,
          description: "Nhập tồn đầu: #{cat_name}"
        )
        details = []

        # Header, first table row
        headers = sheet.row(3)

        sheet.each_row_streaming do |row|
          if row[0].present? and row[0].value.present? and row[1].present? and row[1].value.to_i > 0
            category = Erp::Products::Category.where(name: cat_name).first

            # quantity
            stock = row[1].value
            pname = row[0].value

            # Find product
            product = Erp::Products::Product
              .where(name: pname)
              .first

            # check if product exist
            if product.present?
              result = "SUCCESS::#{pname}: exist! checked! (#{stock})"

              # add stock check detail
              details << stock_check.stock_check_details.build(
                product_id: product.id,
                quantity: stock,
                state_id: state.id
              )
            else
              result = "ERROR::#{lns[0]}: ppvs not exist! ignored! (#{stock})"
            end

            # Logging
            puts result
            File.open("tmp/import_init_stock-#{timestamp}.log", "a+") { |f| f << "#{result}\n"}
          end
        end

        # Save stock check record
        puts details.count
        self.transaction do
          stock_check.save
        end
      end




      ################################################# SẢN PHẨM KHÁC ###############################################
      #if ["Sản phẩm khác"].include?(cat_name)
      #  # Stock check
      #  stock_check = Erp::Products::StockCheck.new(
      #    creator_id: user.id,
      #    warehouse_id: warehouse.id,
      #    adjustment_date: Time.now,
      #    employee_id: user.id,
      #    status: Erp::Products::StockCheck::STATUS_DONE,
      #    adjustment_date: '2010-01-01'.to_date,
      #    description: "Nhập tồn đầu: #{cat_name}"
      #  )
      #  details = []
      #
      #  # Header, first table row
      #  headers = sheet.row(3)
      #
      #  sheet.each_row_streaming do |row|
      #    if row[1].present? and row[1].value.present? and row[3].present? and row[3].value.to_i > 0
      #      category_name = row[0].value
      #
      #      # Properties
      #      category = Erp::Products::Category.where(name: category_name).first
      #
      #      if category.present?
      #        pname = row[1].value
      #        stock = row[3].value.to_i
      #
      #        # Find product
      #        product = Erp::Products::Product
      #          .where(name: pname)
      #          .first
      #
      #        # check if product exist
      #        if product.present?
      #          result = "SUCCESS::exist::#{pname}: checked! (#{stock})"
      #        else
      #          #user = Erp::User.first
      #          #brand = Erp::Products::Brand.where(name: "Ortho-K").first
      #          #unit_cai = Erp::Products::Unit.where(name: "Cái").first
      #          #
      #          #product = Erp::Products::Product.create(
      #          #  code: "#{letter_ppv.value}#{number_ppv.value}",
      #          #  name: pname,
      #          #  category_id: category.id,
      #          #  brand_id: brand.id,
      #          #  creator_id: user.id,
      #          #  unit_id: unit_cai.id,
      #          #  price: nil, # rand(5..100)*10000,
      #          #  is_outside: true
      #          #)
      #          #
      #          #Erp::Products::ProductsValue.create(
      #          #  product_id: product.id,
      #          #  properties_value_id: diameter_ppv.id
      #          #) if diameter_ppv.present?
      #          #Erp::Products::ProductsValue.create(
      #          #  product_id: product.id,
      #          #  properties_value_id: letter_ppv.id
      #          #) if letter_ppv.present?
      #          #Erp::Products::ProductsValue.create(
      #          #  product_id: product.id,
      #          #  properties_value_id: number_ppv.id
      #          #) if number_ppv.present?
      #          #
      #          #Erp::Products::Product.find(product.id).update_cache_properties
      #
      #          result = "SUCCESS::not exist::#{pname}: created! checked! (#{stock})"
      #        end
      #
      #        ## add stock check detail
      #        #details << stock_check.stock_check_details.build(
      #        #  product_id: product.id,
      #        #  quantity: stock,
      #        #  state_id: state.id
      #        #)
      #      else
      #        result = "ERROR::#{row[1].value}: category not exist! ignored! (#{stock})"
      #      end
      #
      #      # Logging
      #      puts result
      #      File.open("tmp/import_init_stock-#{timestamp}.log", "a+") { |f| f << "#{result}\n"}
      #    end
      #  end
      #
      #  # Save stock check record
      #  puts details.count
      #  #self.transaction do
      #  #  stock_check.save
      #  #end
      #end




      ################################################# LEN NGOÀI BẢNG ###############################################
      #if ["Len ngoài bảng"].include?(cat_name)
      #  # Stock check
      #  stock_check = Erp::Products::StockCheck.new(
      #    creator_id: user.id,
      #    warehouse_id: warehouse.id,
      #    adjustment_date: Time.now,
      #    employee_id: user.id,
      #    status: Erp::Products::StockCheck::STATUS_DONE,
      #    adjustment_date: '2010-01-01'.to_date,
      #    description: "Nhập tồn đầu: #{cat_name}"
      #  )
      #  details = []
      #
      #  # Header, first table row
      #  headers = sheet.row(3)
      #
      #  sheet.each_row_streaming do |row|
      #    if row[3].present? and row[3].value.to_i >= 0
      #      cat_name = row[2].value
      #      category = Erp::Products::Category.where(name: cat_name).first
      #      lns = row[0].value.scan(/\d+|\D+/)
      #
      #      # diameter
      #      diameter_p = Erp::Products::Property.get_diameter
      #      diameter_ppv = Erp::Products::PropertiesValue.where(property_id: diameter_p.id, value: row[1].value).first
      #
      #      # quantity
      #      stock = row[3].value
      #
      #      # letter
      #      letter_p = Erp::Products::Property.get_letter
      #      letter_ppv = Erp::Products::PropertiesValue.where(property_id: letter_p.id, value: lns[0]).first
      #
      #      # number
      #      number_p = Erp::Products::Property.get_number
      #      number_ppv = Erp::Products::PropertiesValue.where(property_id: number_p.id, value: lns[1].to_i.to_s.rjust(2, '0')).first
      #
      #      if diameter_ppv.present? and letter_ppv.present? and number_ppv.present?
      #        pname = "#{letter_ppv.value}#{number_ppv.value}-#{diameter_ppv.value}-#{cat_name}"
      #
      #        # Find product
      #        product = Erp::Products::Product
      #          .where(name: pname)
      #          .first
      #
      #        # check if product exist
      #        if product.present?
      #          result = "SUCCESS::exist::#{pname}: checked! (#{stock})"
      #        else
      #          #user = Erp::User.first
      #          #brand = Erp::Products::Brand.where(name: "Ortho-K").first
      #          #unit_cai = Erp::Products::Unit.where(name: "Cái").first
      #          #
      #          #product = Erp::Products::Product.create(
      #          #  code: "#{letter_ppv.value}#{number_ppv.value}",
      #          #  name: pname,
      #          #  category_id: category.id,
      #          #  brand_id: brand.id,
      #          #  creator_id: user.id,
      #          #  unit_id: unit_cai.id,
      #          #  price: nil, # rand(5..100)*10000,
      #          #  is_outside: true
      #          #)
      #          #
      #          #Erp::Products::ProductsValue.create(
      #          #  product_id: product.id,
      #          #  properties_value_id: diameter_ppv.id
      #          #) if diameter_ppv.present?
      #          #Erp::Products::ProductsValue.create(
      #          #  product_id: product.id,
      #          #  properties_value_id: letter_ppv.id
      #          #) if letter_ppv.present?
      #          #Erp::Products::ProductsValue.create(
      #          #  product_id: product.id,
      #          #  properties_value_id: number_ppv.id
      #          #) if number_ppv.present?
      #          #
      #          #Erp::Products::Product.find(product.id).update_cache_properties
      #
      #          result = "SUCCESS::not exist::#{pname}: created! checked! (#{stock})"
      #        end
      #
      #        ## Set is outside len
      #        #product.update_attribute(:is_outside, true)
      #        #
      #        ## add stock check detail
      #        #details << stock_check.stock_check_details.build(
      #        #  product_id: product.id,
      #        #  quantity: stock,
      #        #  state_id: state.id
      #        #)
      #      else
      #        result = "ERROR::not exist::#{row[0].value}: ppvs ignored! (#{stock})"
      #      end
      #
      #      # Logging
      #      puts result
      #      File.open("tmp/import_init_stock-#{timestamp}.log", "a+") { |f| f << "#{result}\n"}
      #    end
      #  end
      #
      #  # Save stock check record
      #  puts details.count
      #  #self.transaction do
      #  #  stock_check.save
      #  #end
      #end




    end
  end

  # Combine/Split: Product parts
  def split_parts(quantity, options={}) # options: user, warehouse, state
    return false if parts.empty?

    # Stock check
    stock_check = Erp::Products::StockCheck.new(
      creator_id: options[:user].id,
      warehouse_id: options[:warehouse].id,
      adjustment_date: Time.now,
      employee_id: options[:user].id,
      status: Erp::Products::StockCheck::STATUS_DONE,
      description: "Tách sản phẩm"
    )

    # reduce parent
    stock_check.stock_check_details.build(
      product_id: self.id,
      quantity: -quantity,
      state_id: options[:state].id,
      stock: self.get_stock(state: options[:state], warehouse: options[:warehouse]),
      real: self.get_stock(state: options[:state], warehouse: options[:warehouse]) - quantity,
      note: "Được tách ra"
    )

    # add parts
    self.products_parts.each do |part|
      amount = quantity*part.quantity

      stock_check.stock_check_details.build(
        product_id: part.part_id,
        quantity: amount,
        state_id: options[:state].id,
        stock: part.part.get_stock(state: options[:state], warehouse: options[:warehouse]),
        real: part.part.get_stock(state: options[:state], warehouse: options[:warehouse]) + amount,
        note: "Tách từ #{self.name}"
      )

      # save to database
      Erp::Products::Product.transaction do
        stock_check.save
      end
    end
  end

  def combine_parts(quantity, options={}) # options: user, warehouse, state
    return false if parts.empty?

    # Stock check
    stock_check = Erp::Products::StockCheck.new(
      creator_id: options[:user].id,
      warehouse_id: options[:warehouse].id,
      adjustment_date: Time.now,
      employee_id: options[:user].id,
      status: Erp::Products::StockCheck::STATUS_DONE,
      description: "Ghép sản phẩm"
    )

    # reduce parent
    stock_check.stock_check_details.build(
      product_id: self.id,
      quantity: quantity,
      state_id: options[:state].id,
      stock: self.get_stock(state: options[:state], warehouse: options[:warehouse]),
      real: self.get_stock(state: options[:state], warehouse: options[:warehouse]) + quantity,
      note: "Được ghép thêm"
    )

    # add parts
    self.products_parts.each do |part|
      amount = quantity*part.quantity

      stock_check.stock_check_details.build(
        product_id: part.part_id,
        quantity: -amount,
        state_id: options[:state].id,
        stock: part.part.get_stock(state: options[:state], warehouse: options[:warehouse]),
        real: part.part.get_stock(state: options[:state], warehouse: options[:warehouse]) - amount,
        note: "Ghép cho #{self.name}"
      )

      # save to database
      Erp::Products::Product.transaction do
        stock_check.save
      end
    end
  end

  def get_combine_max_quantity(options={})
    return 0 if parts.empty?
    max = 1000
    self.products_parts.each do |pp|
      amount = (pp.part.get_stock(state: options[:state], warehouse: options[:warehouse])/pp.quantity).to_i
      if amount < max
        max = amount
      end
    end
    return max
  end

  # Get matrix rows columns
  def self.matrix_rows
    [
      {number: '01', degree_k: 'K1'},
      {number: '02', degree_k: 'K2'},
      {number: '03', degree_k: 'K3'},
      {number: '04', degree_k: 'K4'},
      {number: '05', degree_k: '46.00/7.34'},
      {number: '06', degree_k: '45.75/7.37'},
      {number: '07', degree_k: '45.50/7.42'},
      {number: '08', degree_k: '45.25/7.46'},
      {number: '09', degree_k: '45.00/7.50'},
      {number: '10', degree_k: '44.75/7.54'},
      {number: '11', degree_k: '44.50/7.58'},
      {number: '12', degree_k: '44.25/7.63'},
      {number: '13', degree_k: '44.00/7.67'},
      {number: '14', degree_k: '43.75/7.71'},
      {number: '15', degree_k: '43.50/7.75'},
      {number: '16', degree_k: '43.25/7.80'},
      {number: '17', degree_k: '43.00/7.84'},
      {number: '18', degree_k: '42.75/7.89'},
      {number: '19', degree_k: '42.50/7.94'},
      {number: '20', degree_k: '42.25/7.98'},
      {number: '21', degree_k: '42.00/8.03'},
      {number: '22', degree_k: '41.75/8.08'},
      {number: '23', degree_k: '41.50/8.13'},
      {number: '24', degree_k: '41.25/8.18'},
      {number: '25', degree_k: '41.00/8.23'},
      {number: '26', degree_k: '40.75/8.28'},
      {number: '27', degree_k: '40.50/8.33'},
      {number: '28', degree_k: '40.25/8.38'},
      {number: '29', degree_k: '40.00/8.44'},
      {number: '30', degree_k: 'K30'},
      {number: '31', degree_k: 'K31'},
      {number: '32', degree_k: 'K32'},
      {number: '33', degree_k: 'K33'},
      {number: '34', degree_k: 'K34'},
      {number: '35', degree_k: 'K35'},
      {number: '36', degree_k: 'K36'},
    ]
  end

  # Get matrix rows columns
  def self.matrix_cols
    arr = []

    letters = ('A'..'T').to_a
    ('C'..'U').each do |x|
      letters << "H#{x}"
    end

    do_v = 0.5
    letters.each do |letter|
      arr << {letter: letter, degree: do_v.to_s}
      do_v = do_v + 0.25
    end

    arr
  end

  ####################################### GET REQUEST PRODUCT ##########################
  # @todo export
  def self.get_order_request_count(params={})
    stock = 0

    main_query = self.get_order_query(params)

    # consignment detail with order detail
    query = main_query.where(erp_orders_orders: {supplier_id: Erp::Contacts::Contact::MAIN_CONTACT_ID})

    if params[:product_id].present?
      query = query.where(request_product_id: params[:product_id])
    end

    stock = stock + query.sum("erp_orders_order_details.quantity")

    return stock
  end

  # Get related numbers
  def get_alternative_numbers(options={})

    number = self.get_number.to_i

    # alternative arr
    arr = []

    # 15
    arr << number.to_s.rjust(2, '0')

    # 14
    arr << (number - 1).to_s.rjust(2, '0') if number > 1

    # 16
    arr << (number + 1).to_s.rjust(2, '0') if number < 33

    # J
    arr << (number - 2).to_s.rjust(2, '0') if number > 2

     # 16
    arr << (number + 2).to_s.rjust(2, '0') if number < 32

    return arr
  end

  # Get related letter
  def get_alternative_letters(options={})

    letter = self.get_letter

    # letter array
    letters = ('A'..'T').to_a
    ('C'..'U').each do |x|
      letters << "H#{x}"
    end

    # alternative arr
    arr = []

    # K
    arr << letter

    # L
    lt = (letters.index(letter).present? ? letters[letters.index(letter)+1] : nil)
    arr << lt if lt.present?

    # M
    lt = (letters.index(letter).present? ? letters[letters.index(letter)+2] : nil)
    arr << lt if lt.present?

    # J
    lt = (letters.index(letter).present? and letters.index(letter) > 0) ? letters[letters.index(letter)-1] : nil
    arr << lt if lt.present?

    # I
    lt = (letters.index(letter).present? and letters.index(letter) > 0) ? letters[letters.index(letter)-2] : nil
    arr << lt if lt.present?

    # N
    lt = (letters.index(letter).present? ? letters[letters.index(letter)+3] : nil)
    arr << lt if lt.present?

    return arr
  end

  # Get alternative array map
  def get_alternative_array(options={})

    letter = self.get_letter
    number = self.get_number
    diameter = self.get_diameter

    # letter array
    letters = ('A'..'T').to_a
    ('C'..'U').each do |x|
      letters << "H#{x}"
    end

    # alternative arr
    arr = []

    # K15
    arr << {index: 0, number: number, letter: letter}

    # L15
    lt = (letters.index(letter).present? ? letters[letters.index(letter)+1] : nil)
    arr << {index: 1, number: number, letter: lt}

    # M15
    lt = (letters.index(letter).present? ? letters[letters.index(letter)+2] : nil)
    arr << {index: 2, number: number, letter: lt}

    # J15
    lt = (letters.index(letter).present? and letters.index(letter) > 0) ? letters[letters.index(letter)-1] : nil
    arr << {index: 3, number: number, letter: lt}

    # I15
    lt = (letters.index(letter).present? and letters.index(letter) > 0) ? letters[letters.index(letter)-2] : nil
    arr << {index: 4, number: number, letter: lt}

    # L14
    lt = (letters.index(letter).present? ? letters[letters.index(letter)+1] : nil)
    arr << {index: 5, number: (number.to_i-1).to_s.rjust(2, '0'), letter: lt}

    # K14
    arr << {index: 6, number: (number.to_i-1).to_s.rjust(2, '0'), letter: letter}

    # K16
    arr << {index: 7, number: (number.to_i+1).to_s.rjust(2, '0'), letter: letter}

    # M13
    lt = (letters.index(letter).present? ? letters[letters.index(letter)+2] : nil)
    arr << {index: 8, number: (number.to_i-2).to_s.rjust(2, '0'), letter: letter}

    # K13
    arr << {index: 9, number: (number.to_i-2).to_s.rjust(2, '0'), letter: letter}

    # K17
    arr << {index: 10, number: (number.to_i+2).to_s.rjust(2, '0'), letter: letter}

    # N15
    lt = (letters.index(letter).present? ? letters[letters.index(letter)+3] : nil)
    arr << {index: 11, number: number.to_s.rjust(2, '0'), letter: lt}

    # J16
    lt = (letters.index(letter).present? ? letters[letters.index(letter)-1] : nil)
    arr << {index: 12, number: (number.to_i+1).to_s.rjust(2, '0'), letter: lt}

    return arr
  end

  # get alternative products
  def get_alternative_products(options={})
    a_products = []

    arr = self.get_alternative_array(options)
    cat = self.category_name

    # find
    arr.each do |item|
      if item[:number].present? and item[:number].to_i > 0 and item[:letter].present?
        pname = "#{item[:letter]}#{item[:number]}-%-#{cat}"

        products = Erp::Products::Product.where('erp_products_products.name LIKE ?', pname)

        # min
        if options[:min_stock].present?
          products = products.where('cache_stock >= ?', options[:min_stock])
        end

        products.each do |p|
          a_products << {product: p, index: item[:index]} if p.cache_stock.to_i > 0
        end
      end
    end

    return a_products
  end

  # data for dataselect ajax
  def self.dataselect(keyword='', params={})
    query = self.all

    if params[:related_with].present? # and !keyword.present?
      product = self.find(params[:related_with])
      items = product.get_alternative_products
      if params[:current_value].present?
        items = items.reject {|item| params[:current_value].split(',').include?(item.id.to_s)}
      end
      return items.map{ |product| {value: product.id, text: product.name_with_stock} }
    end

    # single keyword
    if keyword.present?
      keyword = keyword.strip.downcase
      keyword.split(' ').each do |q|
        q = q.strip
        query = query.where('LOWER(erp_products_products.cache_search) LIKE ? OR LOWER(erp_products_products.cache_search) LIKE ? OR LOWER(erp_products_products.cache_search) LIKE ?', q+'%', '% '+q+'%', '%-'+q+'%')
      end
    end

    # has part
    if params[:has_parts].present? and params[:has_parts] == 'true'
      query = query.joins(:products_parts).where("erp_products_products_parts.id IS NOT NULL")
    end

    if Erp::Core.available?("orders")
      # product from order
      if params[:order_id].present?
        query = query.includes(:order_details)
          .where(erp_orders_order_details: {order_id: params[:order_id]})

        if Erp::Core.available?("qdeliveries")
          if params[:delivery_type].present?
            if [Erp::Qdeliveries::Delivery::TYPE_SALES_EXPORT, Erp::Qdeliveries::Delivery::TYPE_PURCHASE_IMPORT].include?(params[:delivery_type])
              query = query.where(erp_orders_order_details: {cache_delivery_status: Erp::Orders::OrderDetail::DELIVERY_STATUS_NOT_DELIVERY})
            end
          end
        end
      end
    end

    if Erp::Core.available?("ortho_k")
      if params[:show_stock] == 'true'
        query = query.distinct.order(:name).limit(80).map{|product| {value: product.id, text: product.name_with_stock} }
      else
        query = query.distinct.order(:name).limit(80).map{|product| {value: product.id, text: product.name} }
      end
    else
      query = query.distinct.order(:name).limit(80).map{|product| {value: product.id, text: product.name} }
    end
  end

  # Get cache stock
  def get_cache_stock(options={})
    Erp::Products::CacheStock.get_stock(self.id, options)
  end

  # update ordered code
  after_save :update_ordered_code
  def get_ordered_code
    tmp = code
    if !tmp.match('[A-Z]{2}[0-9]{2}').nil?
      tmp[0] = 'Z'
      return tmp
    end

    return code
  end

  def update_ordered_code
    diameter = self.get_diameter

    if diameter.present?
      tmp = "#{category_name}-#{diameter}-#{self.get_ordered_code}"
    else
      tmp = nil
    end

    self.update_column(:ordered_code, tmp)
  end

  def self.dataselect_category_diameter
    lens = Erp::Products::Category.get_lens
    diameters = Erp::Products::PropertiesValue.diameter_values

    arr = []
    lens.each do |len|
      diameters.each do |diameter|
        if len.name != 'Custom'
          arr << {value: "#{len.id}-#{diameter.id}", text: "#{len.name}-#{diameter.value}"}
        end
      end
    end

    arr
  end

  # Get by properties values
  def self.find_by_properties_value_ids(arr=[])
    query = self
    arr.each do |x|
      query = query.where("erp_products_products.cache_properties LIKE ?", "%[\"#{x}\",%") if x.present?
    end
    query
  end

  # purchase
  def get_purchase_price(options={})
    Erp::Prices::Price.get_by_product(
      contact_id: nil,
      category_id: self.category_id,
      properties_value_id: self.get_diameter_id,
      quantity: options[:quantity].to_i,
      type: 'purchase'
    )
  end
end
