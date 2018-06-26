Erp::Orders::Order.class_eval do
  belongs_to :doctor, class_name: "Erp::Contacts::Contact", foreign_key: :doctor_id, optional: true
  belongs_to :patient, class_name: "Erp::Contacts::Contact", foreign_key: :patient_id, optional: true
  belongs_to :hospital, class_name: "Erp::Contacts::Contact", foreign_key: :hospital_id, optional: true
  belongs_to :patient_state, class_name: "Erp::OrthoK::PatientState", foreign_key: :patient_state_id, optional: true

  # class const
  POSITION_LEFT = 'left'
  POSITION_RIGHT = 'right'
  POSITION_BOTH = 'both'

  SORT_BY_RECORD_DATE = 'record_date'
  SORT_BY_VOUCHER_DATE = 'voucher_date'

  ORDER_BY_DESC = 'desc'
  ORDER_BY_ASC = 'asc'

  GROUPED_BY_DEFAULT = 'grouped_by_default'
  GROUPED_BY_CUSTOMER = 'grouped_by_customer'
  GROUPED_BY_VOUCHER_CODE = 'grouped_by_voucher_code'
  GROUPED_BY_PRODUCT_CODE = 'grouped_by_product_code'
  GROUPED_BY_PRODUCT_CATEGORY = 'grouped_by_warehouse'
  GROUPED_BY_WAREHOUSE = 'grouped_by_warehouse'

  TYPE_SALES_EXPORT = 'sales_export'
  TYPE_SALES_IMPORT = 'sales_import'

  def self.sort_by_dates()
    [
      {
        text: I18n.t('erp.ortho_k.backend.sales.report_sales_details.record_date'),
        value: Erp::Orders::Order::SORT_BY_RECORD_DATE
      },
      {
        text: I18n.t('erp.ortho_k.backend.sales.report_sales_details.voucher_date'),
        value: Erp::Orders::Order::SORT_BY_VOUCHER_DATE
      }
    ]
  end

  def self.get_order_direction()
    [
      {text: I18n.t('descending'), value: Erp::Orders::Order::ORDER_BY_DESC},
      {text: I18n.t('ascending'), value: Erp::Orders::Order::ORDER_BY_ASC}
    ]
  end

  def self.get_grouped_bys()
    [
      {
        text: I18n.t('default'),
        value: Erp::Orders::Order::GROUPED_BY_DEFAULT
      },
      {
        text: I18n.t('erp.ortho_k.backend.sales.report_sales_details.customer'),
        value: Erp::Orders::Order::GROUPED_BY_CUSTOMER
      },
      {
        text: I18n.t('erp.ortho_k.backend.sales.report_sales_details.voucher_code'),
        value: Erp::Orders::Order::GROUPED_BY_VOUCHER_CODE
      },
      {
        text: I18n.t('erp.ortho_k.backend.sales.report_sales_details.product_code'),
        value: Erp::Orders::Order::GROUPED_BY_PRODUCT_CODE
      },
      {
        text: I18n.t('erp.ortho_k.backend.sales.report_sales_details.product_category'),
        value: Erp::Orders::Order::GROUPED_BY_PRODUCT_CATEGORY
      },
      {
        text: I18n.t('erp.ortho_k.backend.sales.report_sales_details.warehouse'),
        value: Erp::Orders::Order::GROUPED_BY_WAREHOUSE
      }
    ]
  end

  # get type options for contact
  def self.get_eye_positions()
    [
      {text: I18n.t('left_eye'), value: self::POSITION_LEFT},
      {text: I18n.t('right_eye'), value: self::POSITION_RIGHT},
      {text: I18n.t('both_eyes'), value: self::POSITION_BOTH}
    ]
  end

  def self.get_import_export_type_options()
    [
      {text: I18n.t('sales_export'), value: Erp::Orders::Order::TYPE_SALES_EXPORT},
      {text: I18n.t('sales_import'), value: Erp::Orders::Order::TYPE_SALES_IMPORT}
    ]
  end

  def doctor_name
    (doctor.present? ? doctor.name : '')
  end

  def patient_name
    (patient.present? ? patient.name : '')
  end

  def hospital_name
    (hospital.present? ? hospital.name : '')
  end

  def patient_state_name
    (patient_state.present? ? patient_state.name : '')
  end

  def display_customer_info
    strs = []
    strs << doctor_name if doctor.present?
    strs << patient_name if patient.present?
    strs << patient_state_name if patient_state.present?

    (strs.empty? ? '' : "(#{strs.join(' / ')})")
  end

  def display_patient_info
    return  {
      name: self.patient.present? ? self.patient_name : '',
      state: self.patient_state.present? ? self.patient_state.name : 'đổi len'
    }
  end

  # group import export
  def self.group_sales_details_report(params={}, limit=nil)
    rows = self.sales_details_report(params, limit)[:data]

    group_value = :record_date
    group_text = :record_date
    sort_value = :record_date

    # Grouped by
    if params[:group_by] == Erp::Orders::Order::GROUPED_BY_DEFAULT
      group_value = :record_date
      group_text = :record_date
    end

    if params[:group_by] == Erp::Orders::Order::GROUPED_BY_CUSTOMER
      group_value = :customer_code
      group_text = :customer_name
    end

    if params[:group_by] == Erp::Orders::Order::GROUPED_BY_VOUCHER_CODE
      group_value = :voucher_code
      group_text = :voucher_code
    end

    if params[:group_by] == Erp::Orders::Order::GROUPED_BY_PRODUCT_CODE
      group_value = :product_code
      group_text = :product_code
    end

    if params[:group_by] == Erp::Orders::Order::GROUPED_BY_PRODUCT_CATEGORY
      group_value = :product_category
      group_text = :product_category
    end

    if params[:group_by] == Erp::Orders::Order::GROUPED_BY_WAREHOUSE
      group_value = :warehouse
      group_text = :warehouse
    end

    # Sort by
    if params[:sort_by] == Erp::Orders::Order::SORT_BY_RECORD_DATE
      sort_value = :record_date
    end

    if params[:sort_by] == Erp::Orders::Order::SORT_BY_VOUCHER_DATE
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
        if params[:order_by] == Erp::Orders::Order::ORDER_BY_ASC
          item[:rows] = item[:rows].sort_by! {|a| a[sort_value].to_s}
        elsif params[:order_by] == Erp::Orders::Order::ORDER_BY_DESC
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

        # salesperson_commission_amount
        item[:salesperson_commission_amount] = (item[:rows].map {|i| i[:salesperson_commission_amount].to_f}).sum

        # customer_commission_amount
        item[:customer_commission_amount] = (item[:rows].map {|i| i[:customer_commission_amount].to_f}).sum

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

        # salesperson_commission_amount
        item[:salesperson_commission_amount] = (item[:rows].map {|i| i[:salesperson_commission_amount].to_f}).sum

        # customer_commission_amount
        item[:customer_commission_amount] = (item[:rows].map {|i| i[:customer_commission_amount].to_f}).sum

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
    totals[:salesperson_commission_amount] = (grouped_rows.map {|i| i[:salesperson_commission_amount]}).sum
    totals[:customer_commission_amount] = (grouped_rows.map {|i| i[:customer_commission_amount]}).sum

    return {
      groups: grouped_rows.sort_by! {|a| a[:group_sort_code].to_s},
      totals: totals,
    }
  end

  # get import report
  def self.sales_details_report(params={}, limit=nil)
    result = []

    total = {
      quantity: 0,
      sales_tax_amount: 0,
      sales_discount: 0,
      sales_total_amount: 0,
      purchase_total_amount: 0,
      salesperson_commission_amount: 0,
      customer_commission_amount: 0
    }

    if (params[:types].present? and params[:types].include?(Erp::Orders::Order::TYPE_SALES_EXPORT)) or params[:types].nil?
      # Sales order
      query = Erp::Orders::OrderDetail.joins(:order, :product)
              .where(erp_orders_orders: {supplier_id: Erp::Contacts::Contact.get_main_contact.id})
              .where(erp_orders_orders: {status: Erp::Orders::Order::STATUS_CONFIRMED})

      if params[:from_date].present?
        query = query.where('erp_orders_orders.order_date >= ?', params[:from_date].to_date.beginning_of_day)
      end

      if params[:to_date].present?
        query = query.where('erp_orders_orders.order_date <= ?', params[:to_date].to_date.end_of_day)
      end

      if params[:period].present?
        query = query.where('erp_orders_orders.order_date >= ? AND erp_orders_orders.order_date <= ?',
          Erp::Periods::Period.find(params[:period]).from_date.beginning_of_day,
          Erp::Periods::Period.find(params[:period]).to_date.end_of_day)
      end

      if params[:customer_id].present?
        query = query.where(erp_orders_orders: {customer_id: params[:customer_id]})
      end

      if params[:employee_id].present?
        query = query.where(erp_orders_orders: {employee_id: params[:employee_id]})
      end

      if params[:warehouse_id].present?
        query = query.where(warehouse_id: params[:warehouse_id])
      end

      if params[:category_id].present?
        query = query.where(erp_products_products: {category_id: params[:category_id]})
      end

      if params[:product_id].present?
        query = query.where(product_id: params[:product_id])
      end

      query.each do |order_detail|
        qty = +order_detail.quantity
        sales_price = order_detail.price
        sales_tax_amount = order_detail.tax_amount
        sales_discount = order_detail.discount_amount
        sales_total_amount = order_detail.total
        salesperson_commission_amount = order_detail.commission
        salesperson_percent = ((sales_total_amount != 0 and !salesperson_commission_amount.nil?) ? (salesperson_commission_amount.to_f/sales_total_amount.to_f)*100 : '')
        customer_commission_amount = order_detail.customer_commission
        customer_percent = ((sales_total_amount != 0 and !customer_commission_amount.nil?) ? (customer_commission_amount.to_f/sales_total_amount.to_f)*100 : '')

        result << {
          record_type: 'sales_export',
          record_date: order_detail.order.created_at,
          voucher_date: order_detail.order.order_date,
          voucher_code: order_detail.order.code,
          customer_code: order_detail.order.customer_code,
          customer_name: order_detail.order.customer_name,
          product_code: order_detail.product_code,
          product_diameter: order_detail.product.get_diameter,
          product_category: order_detail.product.category_name,
          product_name: order_detail.product_name,
          description: order_detail.order.note,
          state: 'Mới',
          warehouse: order_detail.warehouse_name,
          unit: order_detail.product.unit_name,
          quantity: order_detail.quantity,
          sales_price: sales_price,
          sales_tax_amount: sales_tax_amount,
          sales_discount: sales_discount,
          sales_total_amount: sales_total_amount,
          doctor_name: order_detail.order.doctor_name,
          eye_position: order_detail.display_eye_position,
          patient_name: order_detail.order.patient_name,
          patient_state_name: order_detail.order.patient_state_name,
          salesperson_name: order_detail.order.employee_name,
          salesperson_percent: salesperson_percent,
          salesperson_commission_amount: salesperson_commission_amount,
          customer_commission_percent: customer_percent,
          customer_commission_amount: customer_commission_amount,
          note: order_detail.description
        }
        total[:quantity] += qty
        total[:sales_tax_amount] += sales_tax_amount.to_f
        total[:sales_discount] += sales_discount.to_f
        total[:sales_total_amount] += sales_total_amount.to_f
        total[:salesperson_commission_amount] += salesperson_commission_amount.to_f
        total[:customer_commission_amount] += customer_commission_amount.to_f
      end
    end

    if (params[:types].present? and params[:types].include?(Erp::Orders::Order::TYPE_SALES_IMPORT)) or params[:types].nil?
      # Qdelivery: Có Chứng Từ
      query = Erp::Qdeliveries::DeliveryDetail.joins(:delivery, :order_detail => :product)
              .where.not(order_detail_id: nil)
              .where(erp_qdeliveries_deliveries: {status: Erp::Qdeliveries::Delivery::STATUS_DELIVERED})
              .where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT})

      if params[:from_date].present?
        query = query.where('erp_qdeliveries_deliveries.date >= ?', params[:from_date].to_date.beginning_of_day)
      end

      if params[:to_date].present?
        query = query.where('erp_qdeliveries_deliveries.date <= ?', params[:to_date].to_date.end_of_day)
      end

      if params[:period].present?
        query = query.where('erp_qdeliveries_deliveries.date >= ? AND erp_qdeliveries_deliveries.date <= ?',
          Erp::Periods::Period.find(params[:period]).from_date.beginning_of_day,
          Erp::Periods::Period.find(params[:period]).to_date.end_of_day)
      end

      if params[:customer_id].present?
        query = query.where(erp_qdeliveries_deliveries: {customer_id: params[:customer_id]})
      end

      if params[:employee_id].present?
        query = query.where(erp_qdeliveries_deliveries: {employee_id: params[:employee_id]})
      end

      if params[:warehouse_id].present?
        query = query.where(warehouse_id: params[:warehouse_id])
      end

      if params[:category_id].present?
        query = query.where(erp_products_products: {category_id: params[:category_id]})
      end

      if params[:product_id].present?
        query = query.where(erp_orders_order_details: {product_id: params[:product_id]})
      end

      query.each do |delivery_detail|
        qty = -delivery_detail.quantity
        purchase_price = delivery_detail.price
        purchase_total_amount = delivery_detail.cache_total

        result << {
          record_type: delivery_detail.delivery.delivery_type,
          record_date: delivery_detail.delivery.created_at,
          voucher_date: delivery_detail.delivery.date,
          voucher_code: delivery_detail.delivery.code,
          customer_code: delivery_detail.delivery.customer.code,
          customer_name: delivery_detail.delivery.customer_name,
          product_code: delivery_detail.product_code,
          product_diameter: delivery_detail.product.get_diameter,
          product_category: delivery_detail.product.category_name,
          product_name: delivery_detail.product_name,
          quantity: qty,
          purchase_price: purchase_price, # Giá trả lại
          purchase_total_amount: purchase_total_amount,
          description: delivery_detail.delivery.note,
          state: delivery_detail.state_name,
          warehouse: delivery_detail.warehouse_name,
          unit: delivery_detail.order_detail.product.unit_name,
          note: delivery_detail.note,
          eye_position: delivery_detail.order_detail.display_eye_position,
          doctor_name: delivery_detail.get_doctor_name,
          patient_name: delivery_detail.get_patient_name,
          patient_state_name: delivery_detail.get_patient_state_name,
          salesperson_name: delivery_detail.delivery.employee_name,
        }
        total[:quantity] += qty
        total[:purchase_total_amount] += purchase_total_amount.to_f
      end

      # Qdelivery: Không Chứng Từ
      query = Erp::Qdeliveries::DeliveryDetail.joins(:delivery, :product)
              .where(order_detail_id: nil)
              .where(erp_qdeliveries_deliveries: {status: Erp::Qdeliveries::Delivery::STATUS_DELIVERED})
              .where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT})

      if params[:from_date].present?
        query = query.where('erp_qdeliveries_deliveries.date >= ?', params[:from_date].to_date.beginning_of_day)
      end

      if params[:to_date].present?
        query = query.where('erp_qdeliveries_deliveries.date <= ?', params[:to_date].to_date.end_of_day)
      end

      if params[:period].present?
        query = query.where('erp_qdeliveries_deliveries.date >= ? AND erp_qdeliveries_deliveries.date <= ?',
          Erp::Periods::Period.find(params[:period]).from_date.beginning_of_day,
          Erp::Periods::Period.find(params[:period]).to_date.end_of_day)
      end

      if params[:customer_id].present?
        query = query.where(erp_qdeliveries_deliveries: {customer_id: params[:customer_id]})
      end

      if params[:employee_id].present?
        query = query.where(erp_qdeliveries_deliveries: {employee_id: params[:employee_id]})
      end

      if params[:warehouse_id].present?
        query = query.where(warehouse_id: params[:warehouse_id])
      end

      if params[:category_id].present?
        query = query.where(erp_products_products: {category_id: params[:category_id]})
      end

      if params[:product_id].present?
        query = query.where(product_id: params[:product_id])
      end

      query.each do |delivery_detail|
        qty = -delivery_detail.quantity
        purchase_price = delivery_detail.price
        purchase_total_amount = delivery_detail.cache_total

        result << {
          record_type: delivery_detail.delivery.delivery_type,
          record_date: delivery_detail.delivery.created_at,
          voucher_date: delivery_detail.delivery.date,
          voucher_code: delivery_detail.delivery.code,
          customer_code: delivery_detail.delivery.customer.code,
          customer_name: delivery_detail.delivery.customer_name,
          product_code: delivery_detail.product_code,
          product_diameter: delivery_detail.product.get_diameter,
          product_category: delivery_detail.product.category_name,
          product_name: delivery_detail.product_name,
          quantity: qty,
          purchase_price: purchase_price, # Giá trả lại
          purchase_total_amount: purchase_total_amount,
          description: delivery_detail.delivery.note,
          state: delivery_detail.state_name,
          warehouse: delivery_detail.warehouse_name,
          unit: delivery_detail.product.unit_name,
          note: delivery_detail.note,
          doctor_name: delivery_detail.get_doctor_name,
          patient_name: delivery_detail.get_patient_name,
          patient_state_name: delivery_detail.get_patient_state_name,
          salesperson_name: delivery_detail.delivery.employee_name,
        }
        total[:quantity] += qty
        total[:purchase_total_amount] += purchase_total_amount.to_f
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

  # def get overdue sales order count
  def self.sales_overdue_orders_count
    self.sales_orders.all_overdue.count
  end

  # def get overdue purchase order count
  def self.purchase_overdue_orders_count
    self.purchase_orders.all_overdue.count
  end

  # get report name
  def get_report_name
    str = []
    str << customer_name if customer_name.present?
    #str << doctor_name if doctor_name.present?
    #str << ('BN ' + patient_state_name + ': ' + patient_name) if patient_name.present?
    return 'Xuất bán - ' + str.join(" - ")
  end

  # get all checking orders
  def self.checking_orders
    self.where(status: [
      self::STATUS_STOCK_CHECKING,
      self::STATUS_STOCK_CHECKED,
    ])
  end

  # get all not checking orders
  def self.not_checking_orders
    self.where.not(status: [
      self::STATUS_STOCK_CHECKING,
      self::STATUS_STOCK_CHECKED,
    ])
  end

  # update checking order
  after_save :checking_order_check

  def self.update_checking_order
    self.checking_orders.order('erp_orders_orders.checking_order, erp_orders_orders.created_at DESC').each_with_index do |o, index|
      o.update_column(:checking_order, index+1)
    end
    self.not_checking_orders.update_all(checking_order: nil)
  end

  def self.checking_order_options
    count = self.checking_orders.count
    options = []
    (1..count).each do |num|
      options << {text: num.to_s, value: num}
    end
    options
  end

  def checking_order_check
    if [
      Erp::Orders::Order::STATUS_STOCK_CHECKING,
      Erp::Orders::Order::STATUS_STOCK_CHECKED,
    ].include?(self.status) and self.checking_order.nil?
      self.update_column(:checking_order, 0.5)
    end

    Erp::Orders::Order.update_checking_order
  end

  #
  def import(file, order_params={})
    self.order_details = []
    
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      # Find product
      # p_name = "#{row["code"].to_s.strip}-#{row["diameter"].to_s.strip}-#{row["category"].to_s.strip}"
      p_name = row["name"]

      if p_name.split('-').count == 3
        lns = p_name.scan(/\d+|\D+/)

        # number
        nn_v = lns[1]
        nn_v = nn_v.rjust(2, '0') if nn_v != '0' and nn_v != '00'

        p_name = lns[0] + nn_v + "-" + p_name.split('-')[1] + "-" + p_name.split('-')[2]
      end

      product = Erp::Products::Product.where('name = ?', p_name.strip).first
      product_id = product.present? ? product.id : nil

      if product.present?
        if self.purchase?
          purchase_price = product.get_default_purchase_price(quantity: row[1])
          price = purchase_price.present? ? purchase_price.price : 0.0
        else
          sales_price = product.get_default_sales_price(quantity: row[1])
          price = sales_price.present? ? sales_price.price : 0.0
        end
        
        # warehouse
        warehouse = row["warehouse"].present? ? Erp::Warehouses::Warehouse.where(name: row["warehouse"].strip).first : nil
        warehouse_id = warehouse.present? ? warehouse.id : order_params[:warehouse_id]        
        
        if row["quantity"].to_i > 0
          self.order_details.build(
            id: nil,
            product_id: product_id,
            quantity: row["quantity"],
            serials: row["serials"],
            price: price,
            warehouse_id: warehouse_id,
          )
        end
      end
    end
  end

  after_save :update_cache_for_order_commission_amount
  # update for order payment commission amount
  def update_cache_for_order_commission_amount
    self.done_receiced_payment_records.update_all(:cache_for_order_commission_amount => nil)

    # First one
    if self.payment_for == Erp::Orders::Order::PAYMENT_FOR_ORDER
      first_one =  self.done_receiced_payment_records.order('payment_date asc').first
      first_one.update_columns(cache_for_order_commission_amount: self.cache_commission_amount) if first_one.present?
    end
  end

  def patient_name
    patient.present? ? patient.name : ''
  end

  def doctor_name
    doctor.present? ? doctor.name : ''
  end
  
  def update_default_prices
    self.order_details.each do |od|
      p = 0.0
      
      if self.sales?
        pp = od.product.get_default_sales_price(quantity: od.quantity)
      elsif self.purchase?
        pp = od.product.get_default_purchase_price(quantity: od.quantity)
      end
      
      p = pp.price if pp.present?
      od.update_attribute(:price, p)
    end 
  end
  
  # update cache sales debt amount //contact
  after_save :update_contact_cache_sales_debt_amount
  def update_contact_cache_sales_debt_amount
    if customer.present? and self.sales?
      customer.update_cache_sales_debt_amount
    end
  end
  
  # update cache purchase debt amount //contact
  after_save :update_contact_cache_purchase_debt_amount
  def update_contact_cache_purchase_debt_amount
    if supplier.present? and self.purchase?
      supplier.update_cache_purchase_debt_amount
    end
  end
end
