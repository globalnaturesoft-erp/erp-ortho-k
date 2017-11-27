Erp::Orders::Order.class_eval do
  belongs_to :doctor, class_name: "Erp::Contacts::Contact", foreign_key: :doctor_id, optional: true
  belongs_to :patient, class_name: "Erp::Contacts::Contact", foreign_key: :patient_id, optional: true
  belongs_to :hospital, class_name: "Erp::Contacts::Contact", foreign_key: :hospital_id, optional: true

  def doctor_name
    (doctor.present? ? doctor.name : '')
  end

  def patient_name
    (patient.present? ? patient.name : '')
  end

  def hospital_name
    (hospital.present? ? hospital.name : '')
  end

  def display_customer_info
    strs = []
    strs << doctor.name if doctor.present?
    strs << patient.name if patient.present?

    (strs.empty? ? '' : "(#{strs.join(' / ')})")
  end
  
  def display_patient_info
    return  {
      name: self.patient.present? ? self.patient_name : '',
      state: self.is_new_patient ? 'mới' : 'đổi len'
    }
  end
  
  # get import report
  def self.sales_details_report(params={})
    result = []

    total = {
      quantity: 0
    }
    
    # Sales order
    query = Erp::Orders::OrderDetail.joins(:order)
            .where(erp_orders_orders: {supplier_id: Erp::Contacts::Contact.get_main_contact.id})
            .where(erp_orders_orders: {status: Erp::Orders::Order::STATUS_CONFIRMED})
    
    if params[:from_date].present?
      query = query.where(erp_orders_orders: {'order_date >= ?': params[:from_date].to_date.beginning_of_day})
    end

    if params[:to_date].present?
      query = query.where(erp_orders_orders: {'order_date <= ?': params[:to_date].to_date.end_of_day})
    end
    
    query.each do |order_detail|
      qty = +order_detail.quantity
      #sales_total_amount = delivery_detail.subtotal

      result << {
        record_date: order_detail.order.created_at,
        voucher_date: order_detail.order.order_date,
        voucher_code: order_detail.order.code,
        customer_code: order_detail.order.customer_code,
        customer_name: order_detail.order.customer_name,
        product_name: order_detail.product_name,
        description: order_detail.description,
        state: 'Hàng mới',
        warehouse: order_detail.order.warehouse_name,
        unit: order_detail.product.unit_name,
        quantity: order_detail.quantity,
        sales_price: order_detail.price, # Gia ban
        sales_total_amount: order_detail.subtotal,
        patient_name: order_detail.order.patient_name,
        salesperson_name: order_detail.order.customer.salesperson_name,
        salesperson_commission_amount: order_detail.commission
      }
      total[:quantity] += qty
      #total[:sales_total_amount] += sales_total_amount
    end
    
    # Qdelivery: Có Chứng Từ
    query = Erp::Qdeliveries::DeliveryDetail.joins(:delivery, :order_detail => :product)
            .where.not(order_detail_id: nil)
            .where(erp_qdeliveries_deliveries: {status: Erp::Qdeliveries::Delivery::STATUS_DELIVERED})
            .where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_CUSTOMER_IMPORT})
    
    if params[:from_date].present?
      query = query.where(erp_qdeliveries_deliveries: {'date >= ?': params[:from_date].to_date.beginning_of_day})
    end
    
    if params[:to_date].present?
      query = query.where(erp_qdeliveries_deliveries: {'date <= ?': params[:to_date].to_date.end_of_day})
    end
    
    query.each do |delivery_detail|
        qty = -delivery_detail.quantity
        #sales_total_amount = -(delivery_detail.cache_total)
    
      result << {
        record_date: delivery_detail.delivery.created_at,
        voucher_date: delivery_detail.delivery.date,
        voucher_code: delivery_detail.delivery.code,
        customer_code: delivery_detail.delivery.customer.code,
        customer_name: delivery_detail.delivery.customer_name,
        product_name: delivery_detail.product_name,
        quantity: -(delivery_detail.quantity),
        sales_price: -(delivery_detail.price), # Gia trả lại
        sales_total_amount: -(delivery_detail.cache_total),
        description: delivery_detail.note,
        state: delivery_detail.state_name,
        warehouse: delivery_detail.warehouse_name,
        unit: delivery_detail.order_detail.product.unit_name
      }
      total[:quantity] += qty
      #total[:sales_total_amount] += sales_total_amount
    end
    
    # Qdelivery: Không Chứng Từ
    query = Erp::Qdeliveries::DeliveryDetail.joins(:delivery, :product)
            .where(order_detail_id: nil)
            .where(erp_qdeliveries_deliveries: {status: Erp::Qdeliveries::Delivery::STATUS_DELIVERED})
            .where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_CUSTOMER_IMPORT})
    
    if params[:from_date].present?
      query = query.where(erp_qdeliveries_deliveries: {'date >= ?': params[:from_date].to_date.beginning_of_day})
    end
    
    if params[:to_date].present?
      query = query.where(erp_qdeliveries_deliveries: {'date <= ?': params[:to_date].to_date.end_of_day})
    end
    
    query.each do |delivery_detail|
      qty = -delivery_detail.quantity
      #sales_total_amount = -(delivery_detail.cache_total)
    
      result << {
        record_date: delivery_detail.delivery.created_at,
        voucher_date: delivery_detail.delivery.date,
        voucher_code: delivery_detail.delivery.code,
        customer_code: delivery_detail.delivery.customer.code,
        customer_name: delivery_detail.delivery.customer_name,
        product_name: delivery_detail.product_name,
        quantity: -(delivery_detail.quantity),
        sales_price: -(delivery_detail.price), # Gia trả lại
        sales_total_amount: -(delivery_detail.cache_total),
        description: delivery_detail.delivery.note,
        state: delivery_detail.state_name,
        warehouse: delivery_detail.warehouse_name,
        unit: delivery_detail.product.unit_name,
      }
      total[:quantity] += qty
      #total[:sales_total_amount] += sales_total_amount
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

    # only not-in-stock products
    query = query.where(cache_stock: 0)

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
end
