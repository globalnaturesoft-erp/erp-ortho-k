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

  # get import report
  def import_export_report(params={})
    return Erp::Products::Product.import_export_report(params.merge({product_id: self.id}))
  end

  # get import report
  def self.import_export_report(params={}, limit=nil)
    result = []

    total = {
      quantity: 0
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
        sales_price: delivery_detail.order_detail.present? ? delivery_detail.order_detail.price : '',
        sales_total_amount: delivery_detail.order_detail.present? ? delivery_detail.order_detail.subtotal : '',
      }
      total[:quantity] += qty
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
        quer = Erp::StockTransfers::TransferDetail.joins(:transfer)
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

    # Gift Given /Tặng Quà
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

    # Consignment: Hàng ký gửi cho mượn
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

    # Consignment: Hàng ký gửi trả lại
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

    # Damage Record: Hàng xuất hủy
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

    # Stock check
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
        if qty > 0
          qty_export = stock_check_detail.quantity
          source_warehouse = stock_check_detail.stock_check.warehouse_name
        elsif qty < 0
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

    # State check // trạng thái
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

      if params[:state_id].present?
        query = query.where('state_id = ? OR old_state_id = ?', params[:state_id], params[:state_id])
      end

      # Old state
      query.each do |state_check_detail|
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
      query.each do |state_check_detail|
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

    # only not-in-stock products
    if params[:warehouse].present? or params[:state].present?
      state_id = params[:state].present? ? params[:state] : nil
      warehouse_id = params[:warehouse].present? ? params[:warehouse] : nil
      query = query.joins(:cache_stocks)
        .where(erp_products_cache_stocks: {state_id: state_id})
        .where(erp_products_cache_stocks: {warehouse_id: warehouse_id})
        .where(erp_products_cache_stocks: {stock: 0})
    else
      query = query.where(cache_stock: 0)
    end

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

    query = query.where(ors.join(" OR "))

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
      cat_name = name

      # Check if sheet tab is LEN
      if ["Standard"].include?(cat_name)
        # Stock check
        stock_check = Erp::Products::StockCheck.new(
          creator_id: user.id,
          warehouse_id: warehouse.id,
          adjustment_date: Time.now,
          employee_id: user.id,
          status: Erp::Products::StockCheck::STATUS_DONE
        )
        details = []

        # Header, first table row
        headers = sheet.row(2)

        # description
        stock_check.description = "Nhập kho ban đầu: #{cat_name}"

        headers.each_with_index do |header, index|
          if ["10.4","10.6","10.8","11","11.2","11.4"].include?(header.to_s)
            # diameter
            diameter_p = Erp::Products::Property.get_diameter
            diameter_ppv = Erp::Products::PropertiesValue.where(property_id: diameter_p.id, value: header.to_s).first

            sheet.each_row_streaming do |row|
              if !row[index].empty? and row[index].value > 0 and !["10.4","10.6","10.8","11","11.2","11.4"].include?(row[index].value.to_s)
                lns = row[0].value.scan(/\d+|\D+/)

                # quantity
                stock = row[index].value

                # letter
                letter_p = Erp::Products::Property.get_letter
                letter_ppv = Erp::Products::PropertiesValue.where(property_id: letter_p.id, value: lns[0]).first

                # number
                number_p = Erp::Products::Property.get_number
                number_ppv = Erp::Products::PropertiesValue.where(property_id: number_p.id, value: lns[1].rjust(2, '0')).first

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

                    result = "SUCCESS::#{pname}: exist! checked!"
                  else
                    result = "ERROR::#{pname}: not exist! ignored!"
                  end
                end

                # Logging
                puts result
                # File.open("tmp/import_init_stock-#{timestamp}.log", "a+") { |f| f << "#{result}\n"}
                # sleep 1
              end
            end
          end
        end

        # Save stock check record
        puts details.count
        self.transaction do
          stock_check.save
        end
      end
    end

  end

end
