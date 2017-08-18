Erp::Products::Product.class_eval do
  has_many :transfer_details, class_name: 'Erp::StockTransfers::TransferDetail'
  
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
end
