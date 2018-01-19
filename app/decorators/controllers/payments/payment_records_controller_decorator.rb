Erp::Payments::Backend::PaymentRecordsController.class_eval do
  def xlsx_export_liabilities
    @from = (params[:from_date].present?) ? params[:from_date].to_date : Time.now.beginning_of_month
    @to = (params[:to_date].present?) ? params[:to_date].to_date : Time.now

    @customer = Erp::Contacts::Contact.find(params[:customer_id])
    @orders = @customer.sales_orders.payment_for_contact_orders(params.to_unsafe_hash)
    @product_returns = @customer.sales_product_returns.get_deliveries_with_payment_for_contact(params.to_unsafe_hash)
    
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="Bang cong no khach hang.xlsx"'
      }
    end
  end
  
  # Commission with ForOrder / Export excel
  def commission_with_for_order_xlsx
    @global_filters = params.to_unsafe_hash[:global_filter]

    # if has period
    if @global_filters[:period].present?
      @period = Erp::Periods::Period.find(@global_filters[:period])
    
      @options = {
        from_date: @period.from_date.beginning_of_day,
        to_date: @period.to_date.end_of_day,
        target_period: @period,
      }
    end
    
    @employee = Erp::User.find(params[:employee_id])
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename='#{@employee.name} - hoa hong thu ban le.xlsx'"
      }
    end
  end
  
  # Commission with ForContact / Export excel
  def commission_with_for_contact_xlsx
    @employee = Erp::User.find(params[:employee_id])
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename='#{@employee.name} - hoa hong thu cong no.xlsx'"
      }
    end
  end
  
  # Commission with employee target / Export excel
  def employee_target_xlsx
    @global_filters = params.to_unsafe_hash[:global_filter]

    # if has period
    if @global_filters[:period].present?
      @period = Erp::Periods::Period.find(@global_filters[:period])
    end
    
    @options = {
      from_date: @period.from_date.beginning_of_day,
      to_date: @period.to_date.end_of_day,
      target_period: @period,
    }

    @employees = Erp::User.where('id != ?', Erp::User.first.id)
    @employees = Erp::User.where(id: @global_filters[:employee]) if @global_filters[:employee].present?
    
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename='Danh sach thuong theo target.xlsx'"
      }
    end
  end
  
  # Commission with company target / Export excel
  def company_target_xlsx
    @global_filters = params.to_unsafe_hash[:global_filter]

    # if has period
    if @global_filters[:period].present?
      @period = Erp::Periods::Period.find(@global_filters[:period])
    end

    @employees = Erp::User.where('id != ?', Erp::User.first.id)
    @employees = Erp::User.where(id: @global_filters[:employee]) if @global_filters[:employee].present?
    
    @company_target = Erp::Targets::CompanyTarget.get_by_period(@period)
    
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename='Danh sach thuong theo doanh thu.xlsx'"
      }
    end
  end
  
  # Commission / Export excel
  def commission_xlsx
    @global_filters = params.to_unsafe_hash[:global_filter]

    # if has period
    if @global_filters[:period].present?
      @period = Erp::Periods::Period.find(@global_filters[:period])
      
      @options = {
        from_date: @period.from_date.beginning_of_day,
        to_date: @period.to_date.end_of_day,
        target_period: @period,
      }
    end
    
    @employees = Erp::User.where('id != ?', Erp::User.first.id)
    @employees = Erp::User.where(id: @global_filters[:employee]) if @global_filters[:employee].present?
    
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename='Tong ket chi hoa hong.xlsx'"
      }
    end
  end
end