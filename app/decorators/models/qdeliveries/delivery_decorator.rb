Erp::Qdeliveries::Delivery.class_eval do
  # get report name
  def get_report_name
    str = []
    str << customer_name if customer_name.present?
    #str << note.to_s if note.present?
    return 'Hoàn kho - ' + str.join(" - ")
  end
  
  # create related purchase order
  def create_purchase_order
    if delivery_type == Erp::Qdeliveries::Delivery::TYPE_PURCHASE_IMPORT
      order = Erp::Orders::Order.new
      order.order_date = self.date
      order.status = Erp::Orders::Order::STATUS_CONFIRMED
      order.creator_id = self.creator_id
      order.customer_id = Erp::Contacts::Contact.get_main_contact.id
      order.supplier_id = self.supplier_id
      order.warehouse_id = self.delivery_details.first.warehouse_id
      order.employee_id = self.employee_id
      order.payment_for = Erp::Orders::Order::PAYMENT_FOR_CONTACT
      order.note = "[Hệ thống] Tự động tạo từ phiếu nhập NCC"
      order.save
      
      self.delivery_details.each do |dd|
        if dd.order_detail_id.nil?
          od = order.order_details.new
          od.order_id = order.id
          od.product_id = dd.product_id
          od.unit_id = dd.product.unit_id
          od.quantity = dd.quantity
          od.warehouse_id = dd.warehouse_id
          od.price = dd.product.get_default_sales_price(quantity: od.quantity)
          od.save
          
          dd.order_detail_id = od.id
          dd.save
        end
      end
    end
  end
end