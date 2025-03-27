Erp::Orders::OrderDetail.class_eval do
  def display_eye_position
    if self.eye_position.present?
      if [Erp::Orders::Order::POSITION_LEFT,
          Erp::Orders::Order::POSITION_RIGHT].include?(self.eye_position)
        return I18n.t(".#{eye_position}_eye")
      elsif [Erp::Orders::Order::POSITION_BOTH].include?(self.eye_position)
        return I18n.t(".#{eye_position}_eyes")
      else
        return ''
      end
    else
      return ''
    end
  end

  # [Actual] Quantity of goods delivered (Excludes: Hoàn Kho. Nghĩa là chỉ tính xuất và không tính nhập)
  def delivered_quantity
    if order.present? and order.sales?
      import_quantity = 0
      #import_quantity = self.delivered_delivery_details
      #                  .where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT})
      #                  .sum('erp_qdeliveries_delivery_details.quantity')
      export_quantity = self.delivered_delivery_details
                        .where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_SALES_EXPORT})
                        .sum('erp_qdeliveries_delivery_details.quantity')
      return export_quantity - import_quantity
    elsif order.present? and order.purchase?
      import_quantity = self.delivered_delivery_details
                        .where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_PURCHASE_IMPORT})
                        .sum('erp_qdeliveries_delivery_details.quantity')
      #export_quantity = 0
      export_quantity = self.delivered_delivery_details
                        .where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_PURCHASE_EXPORT})
                        .sum('erp_qdeliveries_delivery_details.quantity')

      return -export_quantity + import_quantity
    else
      return 0
    end
  end
  
  # update cache sales debt amount //contact
  after_save :update_contact_cache_sales_debt_amount
  def update_contact_cache_sales_debt_amount
    if order.customer.present? and self.order.sales?
      order.customer.update_cache_sales_debt_amount
    end
  end
  
  # update cache purchase debt amount //contact
  after_save :update_contact_cache_purchase_debt_amount
  def update_contact_cache_purchase_debt_amount
    if order.supplier.present? and self.order.purchase?
      order.supplier.update_cache_purchase_debt_amount
    end
  end
end
