Erp::Payments::Backend::PaymentRecordsController.class_eval do
  def xlsx_export_liabilities
    @from = Time.now.beginning_of_month.beginning_of_day
    @to = Time.now.end_of_day
    
    if params[:from_date].present?
      @from = params[:from_date].to_date.beginning_of_day
    end
    
    if params[:to_date].present?
      @to = params[:to_date].to_date.end_of_day
    end

    @customer = Erp::Contacts::Contact.find(params[:customer_id])
    @orders = @customer.sales_orders.payment_for_contact_orders(params.to_unsafe_hash)
    @product_returns = @customer.sales_product_returns.get_deliveries_with_payment_for_contact(params.to_unsafe_hash)
    @payment_records = Erp::Payments::PaymentRecord.all_done
      .where(customer_id: params[:customer_id])
      .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id)
    
    if params[:from_date].present?
      @payment_records = @payment_records.where('payment_date >= ?', params[:from_date].to_date.beginning_of_day)
    end
    
    if params[:to_date].present?
      @payment_records = @payment_records.where('payment_date <= ?', params[:to_date].to_date.end_of_day)
    end
    
    @orders = @orders.order('order_date ASC, created_at ASC')
    @product_returns = @product_returns.order('date ASC, created_at ASC')
    @payment_records = @payment_records.order('payment_date ASC, created_at ASC')
    
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
    @payment_for_order_sales_payment_records = @employee.payment_for_order_sales_payment_records(@options)
    
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = "attachment; filename='#{@employee.name} - hoa hong thu ban le.xlsx'"
      }
    end
  end
  
  # Commission with ForContact / Export excel
  def commission_with_for_contact_xlsx
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
    @payment_for_contact_sales_payment_records = @employee.payment_for_contact_sales_payment_records(@options).order('payment_date')
    
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
  
  # export all customer commission details
  def export_xlsx_all_details
    @from = Time.now.beginning_of_month.beginning_of_day
    @to = Time.now.end_of_day
    
    glb = params.to_unsafe_hash[:global_filter]
    if glb[:period].present?
      @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
      @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
    else
      if glb[:from_date].present?
        @from = glb[:from_date].to_date.beginning_of_day
      end
      
      if glb[:to_date].present?
        @to = glb[:to_date].to_date.end_of_day
      end
    end
    

    @customers = Erp::Contacts::Contact.search(params)
      .where.not(id: Erp::Contacts::Contact.get_main_contact.id)
    
    if glb[:contact_group_id].present?
      @customers = @customers.where(contact_group_id: glb[:contact_group_id])
    end
    
    if glb[:salesperson_id].present?
      @customers = @customers.where(salesperson_id: glb[:salesperson_id])
    end

    if glb[:customer].present?
      @customers = @customers.where(id: glb[:customer])
    else
      @customers = @customers.where(is_customer: true)
    end

    #filters
    in_period_active = false
    is_debt_active = false
    if params.to_unsafe_hash["filters"].present?
      params.to_unsafe_hash["filters"].each do |ft|
        ft[1].each do |cond|
          if (cond[1]["name"] == 'in_period_active')
            in_period_active = true
          end
          if (cond[1]["name"] == 'is_debt_active')
            is_debt_active = true
          end
        end
      end
    end
    
    if (in_period_active == true) && (is_debt_active == true)
      @customers = @customers.get_sales_liabilities_contacts(from_date: @from, to_date: @to)
    else
      if in_period_active == true
        @customers = @customers.get_sales_payment_chasing_contacts(from_date: @from, to_date: @to)
      elsif is_debt_active == true
        @customers = @customers.get_sales_debt_amount_residual_contacts
      end
    end
    
    ##filters
    #if params.to_unsafe_hash["filters"].present?
    #  params.to_unsafe_hash["filters"].each do |ft|
    #    ft[1].each do |cond|
    #      if cond[1]["name"] == 'in_period_active'
    #        @customers = @customers.get_sales_payment_chasing_contacts(
    #          from_date: @from,
    #          to_date: @to
    #        )
    #      end
    #    end
    #  end
    #end
    #
    #@full_customers = @customers
    
    # create files
    tmp_path = "tmp/#{Time.now.to_i}/"
    Dir.mkdir(tmp_path) unless File.exists?(tmp_path)
    
    @customers.each do |customer|
      file_name = "#{customer.name.to_ascii.gsub(/[^0-9a-z ]/i, '')}-#{customer.id}.xlsx"
      create_xlsx_files(customer, glb, tmp_path, file_name, @from, @to)
    end
    
    # zip files
    temp = Tempfile.new 'cong_no.zip'
    Zip::File.open(temp.path, Zip::File::CREATE) do |zipfile|
      @customers.each do |customer|
        file_name = "#{customer.name.to_ascii.gsub(/[^0-9a-z ]/i, '')}-#{customer.id}.xlsx"
        zipfile.add file_name, tmp_path + file_name
      end
    end

    send_file temp.path, type: "application/zip", x_sendfile: true,
      disposition: "attachment", filename: "ChiTietCongNo.zip"
  end
  
  def create_xlsx_files(customer, glb, tmp_path, file_name, from, to)
    #if glb[:period].present?
    #  @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
    #  @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
    #else
    #  @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
    #  @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
    #end
    
    @from = from
    @to = to

    @customer = customer
    @orders = @customer.sales_orders.payment_for_contact_orders(glb)
    @product_returns = @customer.sales_product_returns.get_deliveries_with_payment_for_contact(glb)
    @payment_records = Erp::Payments::PaymentRecord.all_done
      .where(customer_id: @customer.id)
      .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id)
    
    if @from.present?
      @payment_records = @payment_records.where('payment_date >= ?', @from)
    end
    
    if @to.present?
      @payment_records = @payment_records.where('payment_date <= ?', @to)
    end
    
    @orders = @orders.order('order_date ASC, created_at ASC')
    @product_returns = @product_returns.order('date ASC, created_at ASC')
    @payment_records = @payment_records.order('payment_date ASC, created_at ASC')
    
    xlsx_package = Axlsx::Package.new
    wb = xlsx_package.workbook
    xlsx_package.use_autowidth = true
    wb.styles do |s|
      wb.styles.fonts.first.name = 'Calibri'
      wb.add_worksheet(name: "Chi tiết công nợ") do |sheet|
        # style
        bg_info = {:bg_color => "305496", :fg_color => "FF"}
        bg_subrow = {:bg_color => "dbdbdb", :fg_color => "00"}
        bg_footer = {:bg_color => "ffff00", :fg_color => "c52f24"}
        text_center = {alignment: { horizontal: :center }}
        text_left = {alignment: { horizontal: :left }}
        text_right = {alignment: { horizontal: :right }}
        wrap_text = {alignment: { horizontal: :center, vertical: :center, wrap_text: true}}
        number = {format_code: '#,##0'}
        date_format = {format_code: 'DD/MM/YYYY'}
        border = {border: { style: :thin, color: "00", :edges => [:left, :right, :bottom, :top] }}
        border_dotted_bottom = {border: { style: :dotted, color: "00", :edges => [:bottom] }}
        border_thin_bottom_right = {border: { style: :thin, color: "00", :edges => [:right, :bottom] }}
        bold = {b: true}
        italic = {i: true}
        
        if !@from.nil? and !@to.nil? and (@from.to_date == @to.to_date)
          date = "#{'NGÀY ' + @from.to_date.strftime('%d/%m/%Y')}"
        else
          date = "#{'TỪ ' + @from.to_date.strftime('%d/%m/%Y') if !@from.nil?}#{' ĐẾN ' + @to.to_date.strftime('%d/%m/%Y') if !@to.nil?}"
        end
        
        # Top head
        sheet.add_row ["CÔNG TY TNHH ORTHO-K VIỆT NAM"], b: true
        sheet.add_row ["535 An Dương Vương, Phường 8, Quận 5, TP. Hồ Chí Minh, Việt Nam"], b: true
        
        # add empty row
        sheet.add_row [nil]
        
        sheet.add_row ['BẢNG CHI TIẾT CÔNG NỢ'], sz: 16, b: true, style: (s.add_style text_center)
        sheet.add_row ["(#{date})"], sz: 12, i: true, style: (s.add_style text_center)
        sheet.add_row ["Đối tượng: #{@customer.name}"], sz: 12, b: true, style: (s.add_style text_center)
        
        num_row = 6
        
        # ############################ Chi tiết bán hàng ############################
        
        # add empty row
        sheet.add_row [nil]
        num_row += 1
        sheet.add_row ['1. Chi tiết bán hàng'], b: true
        num_row += 1
        
        if @orders.count > 0
          # header_1
          header_1 = {columns: [], styles: []}
          subheader_1 = {columns: [], styles: []}
          footer_1 = {columns: [], styles: []}
          
          column_widths = []
          
          header_1[:columns] << 'Ngày chứng từ'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << nil
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c = 0
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          column_widths << 15
          
          header_1[:columns] << 'Số chứng từ'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << nil
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          column_widths << 15
          
          header_1[:columns] << 'Diễn giải'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << nil
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          column_widths << 30
          
          header_1[:columns] << 'Chứng từ liên quan'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << nil
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          column_widths << 12
          
          if params[:doctor_col].present?
            header_1[:columns] << 'Bác sĩ'
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_1[:columns] << nil
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
            column_widths << 18
          end
          
          if params[:patient_col].present?
            header_1[:columns] << 'Bệnh nhân'
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_1[:columns] << nil
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
            column_widths <<  18
          end
          
          if params[:patient_state_col].present?
            header_1[:columns] << 'TT BN'
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_1[:columns] << nil
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
            column_widths << 10
          end
          
          if params[:product_state_col].present?
            header_1[:columns] << 'TT SP'
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_1[:columns] << nil
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
            column_widths << 10
          end
          if params[:warehouse_col].present?
            header_1[:columns] << 'Kho'
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_1[:columns] << nil
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
            column_widths << 5
          end
          
          header_1[:columns] << 'ĐVT'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << nil
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          column_widths << 8
          
          header_1[:columns] << 'Số lượng'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << nil
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          column_widths << 10
          qty = c
          
          sales_price_merge_num = (params[:sales_discount_col].present? ? 1 : 0) +
            (params[:sales_total_without_tax_col].present? ? 1 : 0) +
            (params[:sales_tax_col].present? ? 1 : 0) +
            (params[:sales_total_col].present? ? 1 : 0)
          
          header_1[:columns] << "Doanh thu"
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))    
          subheader_1[:columns] << 'Đơn giá'
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          dongia = c
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + (c+sales_price_merge_num)).chr}#{num_row+1}")
          column_widths << 12
          
          if params[:sales_discount_col].present?
            header_1[:columns] << nil
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_1[:columns] << 'Giảm giá'
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            giamgia = c
            column_widths << 12
          end
          
          if params[:sales_total_without_tax_col].present?
            header_1[:columns] << nil
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))    
            subheader_1[:columns] << 'Thành tiền'
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            thanhtien = c
            column_widths << 12
          end
          
          if params[:sales_tax_col].present?
            header_1[:columns] << nil
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))    
            subheader_1[:columns] << 'Tiền thuế'
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            tienthue = c
            column_widths << 12
          end
          
          if params[:sales_total_col].present?
            header_1[:columns] << nil
            header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_1[:columns] << 'Tổng cộng'
            subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            tongcong = c
            column_widths << 12
          end
          
          header_1[:columns] << 'Ghi chú'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << nil
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sales_col_note1 = c
          column_widths << 15
          
          header_1[:columns] << nil
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << nil
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sales_col_note2 = c
          sheet.merge_cells("#{('A'.codepoints.first + sales_col_note1).chr}#{num_row+1}:#{('A'.codepoints.first + sales_col_note2).chr}#{num_row+2}")
          column_widths << 15
          
          sheet.add_row header_1[:columns], style: header_1[:styles]
          num_row += 1
          sheet.add_row subheader_1[:columns], style: subheader_1[:styles]
          num_row += 1
          
          order_num_row_first = num_row + 1
          # rows //Sales orders
          @orders.each do |order|
            row_1 = {columns: [], styles: []}
            
            row_1[:columns] << order.order_date
            row_1[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(date_format).deep_merge(bold).deep_merge(bg_subrow))
            
            row_1[:columns] << order.code
            row_1[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bold).deep_merge(bg_subrow))
            
            row_1[:columns] << order.get_report_name
            row_1[:styles] << (s.add_style border.deep_merge(bold).deep_merge(bg_subrow))
            
            row_1[:columns] << nil
            row_1[:styles] << (s.add_style border.deep_merge(bg_subrow))
            
            if params[:doctor_col].present?
              row_1[:columns] << order.doctor_name
              row_1[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            if params[:patient_col].present?
              row_1[:columns] << order.patient_name
              row_1[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            if params[:patient_state_col].present?
              row_1[:columns] << order.patient_state_name
              row_1[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            if params[:product_state_col].present?
              row_1[:columns] << nil
              row_1[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            if params[:warehouse_col].present?
              row_1[:columns] << nil
              row_1[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            row_1[:columns] << nil # ĐVT
            row_1[:styles] << (s.add_style border.deep_merge(bg_subrow))
            
            row_1[:columns] << nil # order.items_count # SO LUONG
            row_1[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow).deep_merge(text_center))
            
            row_1[:columns] << nil # DON GIA
            row_1[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            
            if params[:sales_discount_col].present?
              row_1[:columns] << nil # order.discount_amount
              row_1[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            end
            
            if params[:sales_total_without_tax_col].present?
              row_1[:columns] << nil # order.total_without_tax
              row_1[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            end
            
            if params[:sales_tax_col].present?
              row_1[:columns] << nil # order.tax_amount
              row_1[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            end
            
            if params[:sales_total_col].present?
              row_1[:columns] << nil # order.cache_total
              row_1[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            end
            
            row_1[:columns] << order.note
            row_1[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bg_subrow))
            
            row_1[:columns] << nil
            row_1[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bg_subrow))
            
            sheet.add_row row_1[:columns], style: row_1[:styles]
            num_row += 1
            
            sheet.merge_cells("#{('A'.codepoints.first + sales_col_note1).chr}#{num_row}:#{('A'.codepoints.first + sales_col_note2).chr}#{num_row}")
            
            order.order_details.each_with_index do |order_detail|
              row_1 = {columns: [], styles: []}
              
              row_1[:columns] << nil
              row_1[:styles] << (s.add_style text_center.deep_merge(border))
              
              row_1[:columns] << nil
              row_1[:styles] << (s.add_style text_left.deep_merge(border))
              
              row_1[:columns] << order_detail.product_name
              row_1[:styles] << (s.add_style text_left.deep_merge(border))
              
              row_1[:columns] << order.code
              row_1[:styles] << (s.add_style text_left.deep_merge(border))
              
              if params[:doctor_col].present?
                row_1[:columns] << nil
                row_1[:styles] << (s.add_style text_left.deep_merge(border))
              end
              
              if params[:patient_col].present?
                row_1[:columns] << nil
                row_1[:styles] << (s.add_style text_left.deep_merge(border))
              end
              
              if params[:patient_state_col].present?
                row_1[:columns] << nil
                row_1[:styles] << (s.add_style text_left.deep_merge(border))
              end
              
              if params[:product_state_col].present?
                row_1[:columns] << 'Mới'
                row_1[:styles] << (s.add_style text_left.deep_merge(border))
              end
              
              if params[:warehouse_col].present?
                row_1[:columns] << order_detail.order.warehouse_name
                row_1[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              end
              
              row_1[:columns] << order_detail.product_unit_name
              row_1[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_1[:columns] << order_detail.quantity
              row_1[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_1[:columns] << order_detail.price
              row_1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              
              if params[:sales_discount_col].present?
                row_1[:columns] << order_detail.discount_amount
                row_1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              end
              
              if params[:sales_total_without_tax_col].present?
                row_1[:columns] << order_detail.total_without_tax
                row_1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              end
              
              if params[:sales_tax_col].present?
                row_1[:columns] << order_detail.tax_amount
                row_1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              end
              
              if params[:sales_total_col].present?
                row_1[:columns] << order_detail.total
                row_1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              end
              
              row_1[:columns] << order_detail.description
              row_1[:styles] << (s.add_style text_left.deep_merge(border))
              
              row_1[:columns] << nil
              row_1[:styles] << (s.add_style text_left.deep_merge(border))
              
              sheet.add_row row_1[:columns], style: row_1[:styles]
              num_row += 1
              
              sheet.merge_cells("#{('A'.codepoints.first + sales_col_note1).chr}#{num_row}:#{('A'.codepoints.first + sales_col_note2).chr}#{num_row}")
            end
          end
          
          # footer
          footer_1[:columns] << 'Tổng cộng'
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(wrap_text).deep_merge(border))
          col_ft_1 = 0
          col_ft_merge = 0
          
          footer_1[:columns] << nil
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_1 += 1
          col_ft_merge += 1
          
          footer_1[:columns] << nil
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_1 += 1
          col_ft_merge += 1
          
          footer_1[:columns] << nil
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_1 += 1
          col_ft_merge += 1
          
          if params[:doctor_col].present?
            footer_1[:columns] << nil
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_1 += 1
            col_ft_merge += 1
          end
          
          if params[:patient_col].present?
            footer_1[:columns] << nil
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_1 += 1
            col_ft_merge += 1
          end
          
          if params[:patient_state_col].present?
            footer_1[:columns] << nil
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_1 += 1
            col_ft_merge += 1
          end
          
          if params[:product_state_col].present?
            footer_1[:columns] << nil
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_1 += 1
            col_ft_merge += 1
          end
          
          if params[:warehouse_col].present?
            footer_1[:columns] << nil
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_1 += 1
            col_ft_merge += 1
          end
          
          footer_1[:columns] << nil # cot don vi tinh
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_1 += 1
          col_ft_merge += 1
          
          # @todo // khong su dung ham SUM truc tiep tren view
          footer_1[:columns] << @orders.sum(&:items_count)#"=SUM(#{('A'.codepoints.first + qty).chr}#{order_num_row_first}:#{('A'.codepoints.first + qty).chr}#{num_row})"
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_center).deep_merge(border))
          col_ft_1 += 1
          
          footer_1[:columns] << nil # cot don gia
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_1 += 1
          
          if params[:sales_discount_col].present?
            footer_1[:columns] << @orders.sum(&:discount_amount)#"=SUM(#{('A'.codepoints.first + giamgia).chr}#{order_num_row_first}:#{('A'.codepoints.first + giamgia).chr}#{num_row})"
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
            col_ft_1 += 1
          end
          
          if params[:sales_total_without_tax_col].present?
            footer_1[:columns] << @orders.sum(&:total_without_tax)#"=SUM(#{('A'.codepoints.first + thanhtien).chr}#{order_num_row_first}:#{('A'.codepoints.first + thanhtien).chr}#{num_row})"
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
            col_ft_1 += 1
          end
          
          if params[:sales_tax_col].present?
            footer_1[:columns] << @orders.sum(&:tax_amount)#"=SUM(#{('A'.codepoints.first + tienthue).chr}#{order_num_row_first}:#{('A'.codepoints.first + tienthue).chr}#{num_row})"
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
            col_ft_1 += 1
          end
          
          if params[:sales_total_col].present?
            footer_1[:columns] << @orders.sum(&:total)#"=SUM(#{('A'.codepoints.first + tongcong).chr}#{order_num_row_first}:#{('A'.codepoints.first + tongcong).chr}#{num_row})"
            footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
            col_ft_1 += 1
          end
          col_amount_ft_1 = col_ft_1
          
          footer_1[:columns] << nil
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(border).deep_merge(border))
          
          footer_1[:columns] << nil
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(border).deep_merge(border))
          
          sheet.add_row footer_1[:columns], style: footer_1[:styles]
          num_row += 1
          row_ft_1 = num_row
          # Merge column total
          sheet.merge_cells("#{('A'.codepoints.first).chr}#{num_row}:#{('A'.codepoints.first + col_ft_merge).chr}#{num_row}")
          
          # Merge colunm note
          sheet.merge_cells("#{('A'.codepoints.first + sales_col_note1).chr}#{num_row}:#{('A'.codepoints.first + sales_col_note2).chr}#{num_row}")
        end
        
        
        # ############################ Chi tiết hàng trả lại ############################
        
        # add empty row
        sheet.add_row [nil]
        num_row += 1
        sheet.add_row ['2. Chi tiết hàng trả lại'], b: true
        num_row += 1
        
        if @product_returns.count > 0
          # header_2
          header_2 = {columns: [], styles: []}
          subheader_2 = {columns: [], styles: []}
          footer_2 = {columns: [], styles: []}
          
          header_2[:columns] << 'Ngày chứng từ'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << nil
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c = 0
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'Số chứng từ'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << nil
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'Diễn giải'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << nil
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'Chứng từ liên quan'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << nil
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          if params[:doctor_col].present?
            header_2[:columns] << 'Bác sĩ'
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << nil
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          end
          
          if params[:patient_col].present?
            header_2[:columns] << 'Bệnh nhân'
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << nil
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          end
          
          if params[:patient_state_col].present?
            header_2[:columns] << 'TT BN'
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << nil
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          end
          
          if params[:product_state_col].present?
            header_2[:columns] << 'TT SP'
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << nil
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          end
          
          if params[:warehouse_col].present?
            header_2[:columns] << 'Kho'
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << nil
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          end
          
          header_2[:columns] << 'ĐVT'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << nil
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'Số lượng'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << nil
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          qty = c
          
          return_price_merge_num = (params[:return_total_without_tax_col].present? ? 1 : 0) +
            (params[:return_discount_col].present? ? 1 : 0) +
            (params[:return_tax_col].present? ? 1 : 0) +
            (params[:return_total_col].present? ? 1 : 0)
          
          header_2[:columns] << 'Doanh thu trả lại'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))    
          subheader_2[:columns] << 'Đơn giá'
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + (c+return_price_merge_num)).chr}#{num_row+1}")
          giamua = c
          
          if params[:return_discount_col].present?
            header_2[:columns] << nil
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << 'Giảm giá'
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            giamgia = c
          end
          
          if params[:return_total_without_tax_col].present?
            header_2[:columns] << nil
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << 'Thành tiền'
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            thanhtien = c
          end
          
          if params[:return_tax_col].present?
            header_2[:columns] << nil
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << 'Tiền thuế'
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            tienthue = c
          end
          
          if params[:return_total_col].present?
            header_2[:columns] << nil
            header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            subheader_2[:columns] << 'Tổng cộng'
            subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
            c += 1
            tongcong = c
          end
          
          header_2[:columns] << 'Ghi chú'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << nil
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          col_note1 = c
          
          header_2[:columns] << nil
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << nil
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          col_note2 = c
          sheet.merge_cells("#{('A'.codepoints.first + col_note1).chr}#{num_row+1}:#{('A'.codepoints.first + col_note2).chr}#{num_row+2}")
          
          sheet.add_row header_2[:columns], style: header_2[:styles]
          num_row += 1
          sheet.add_row subheader_2[:columns], style: subheader_2[:styles]
          num_row += 1
          
          delivery_num_row_first = num_row + 1
          # rows //Sales imports - Product returns
          @product_returns.each do |delivery|
            row_2 = {columns: [], styles: []}
            
            row_2[:columns] << delivery.date
            row_2[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(date_format).deep_merge(bold).deep_merge(bg_subrow))
            
            row_2[:columns] << delivery.code
            row_2[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bold).deep_merge(bg_subrow))
            
            row_2[:columns] << delivery.get_report_name
            row_2[:styles] << (s.add_style border.deep_merge(bold).deep_merge(bg_subrow))
            
            row_2[:columns] << nil
            row_2[:styles] << (s.add_style border.deep_merge(bg_subrow))
            
            if params[:doctor_col].present?
              row_2[:columns] << (delivery.get_related_order.present? ? delivery.get_related_order.doctor_name : nil)
              row_2[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            if params[:patient_col].present?
              row_2[:columns] << (delivery.get_related_order.present? ? delivery.get_related_order.patient_name : nil)
              row_2[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            if params[:patient_state_col].present?
              row_2[:columns] << (delivery.get_related_order.present? ? delivery.get_related_order.patient_state_name : nil)
              row_2[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            if params[:product_state_col].present?
              row_2[:columns] << nil
              row_2[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            if params[:warehouse_col].present?
              row_2[:columns] << nil
              row_2[:styles] << (s.add_style border.deep_merge(bg_subrow))
            end
            
            row_2[:columns] << nil # ĐVT
            row_2[:styles] << (s.add_style border.deep_merge(bg_subrow))
            
            row_2[:columns] << nil # delivery.total_delivery_quantity # SO LUONG
            row_2[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow.deep_merge(text_center)))
            
            row_2[:columns] << nil # DON GIA
            row_2[:styles] << (s.add_style border.deep_merge(bg_subrow))
            
            if params[:return_discount_col].present?
              row_2[:columns] << nil # delivery.discount
              row_2[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            end
            
            if params[:return_total_without_tax_col].present?
              row_2[:columns] << nil # delivery.total_without_tax
              row_2[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            end
            
            if params[:return_tax_col].present?
              row_2[:columns] << nil # delivery.tax_amount
              row_2[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            end
            
            if params[:return_total_col].present?
              row_2[:columns] << nil # delivery.total
              row_2[:styles] << (s.add_style border.deep_merge(number).deep_merge(bold).deep_merge(bg_subrow))
            end
            
            row_2[:columns] << delivery.note
            row_2[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bg_subrow))
            
            row_2[:columns] << nil
            row_2[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bg_subrow))
            
            sheet.add_row row_2[:columns], style: row_2[:styles]
            num_row += 1
            # Merge colunm for delivery detail note
            sheet.merge_cells("#{('A'.codepoints.first + col_note1).chr}#{num_row}:#{('A'.codepoints.first + col_note2).chr}#{num_row}")
            
            delivery.delivery_details.each_with_index do |delivery_detail|
              row_2 = {columns: [], styles: []}
              row_2[:columns] = []
              
              row_2[:columns] << nil
              row_2[:styles] << (s.add_style text_center.deep_merge(border))
              
              row_2[:columns] << nil
              row_2[:styles] << (s.add_style text_center.deep_merge(border))
              
              row_2[:columns] << "#{delivery_detail.product_name}" #{'(' + delivery_detail.get_report_name + ')' if !delivery_detail.get_report_name.empty?}"
              row_2[:styles] << (s.add_style text_left.deep_merge(border))
              
              row_2[:columns] << delivery_detail.get_order_code
              row_2[:styles] << (s.add_style text_left.deep_merge(border))
              
              if params[:doctor_col].present?
                row_2[:columns] << delivery_detail.get_doctor_name
                row_2[:styles] << (s.add_style text_left.deep_merge(border))
              end
              
              if params[:patient_col].present?
                row_2[:columns] << delivery_detail.get_patient_name
                row_2[:styles] << (s.add_style text_left.deep_merge(border))
              end
              
              if params[:patient_state_col].present?
                row_2[:columns] << delivery_detail.get_patient_state_name
                row_2[:styles] << (s.add_style text_left.deep_merge(border))
              end
              
              if params[:product_state_col].present?
                row_2[:columns] << delivery_detail.state_name
                row_2[:styles] << (s.add_style text_center.deep_merge(border))
              end
              
              if params[:warehouse_col].present?
                row_2[:columns] << delivery_detail.warehouse_name
                row_2[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              end
              
              row_2[:columns] << delivery_detail.product_unit
              row_2[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_2[:columns] << delivery_detail.quantity
              row_2[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              #row_2[:columns] << delivery_detail.ordered_price
              row_2[:columns] << delivery_detail.price
              row_2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              
              if params[:return_discount_col].present?
                row_2[:columns] << delivery_detail.discount
                row_2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              end
              
              if params[:return_total_without_tax_col].present?
                #row_2[:columns] << delivery_detail.ordered_subtotal
                row_2[:columns] << delivery_detail.total_without_tax
                row_2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              end
              
              if params[:return_tax_col].present?
                row_2[:columns] << delivery_detail.tax_amount
                row_2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              end
              
              if params[:return_total_col].present?
                row_2[:columns] << delivery_detail.total # OR cache_total
                row_2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              end
              
              row_2[:columns] << delivery_detail.note
              row_2[:styles] << (s.add_style text_left.deep_merge(border))
              
              row_2[:columns] << nil
              row_2[:styles] << (s.add_style text_left.deep_merge(border))
              
              sheet.add_row row_2[:columns], style: row_2[:styles]
              num_row += 1
              # Merge colunm for delivery detail note
              sheet.merge_cells("#{('A'.codepoints.first + col_note1).chr}#{num_row}:#{('A'.codepoints.first + col_note2).chr}#{num_row}")
            end
          end
          
          # footer
          footer_2[:columns] << 'Tổng cộng'
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(wrap_text).deep_merge(border))
          col_ft_2 = 0
          col_ft_merge = 0
          
          footer_2[:columns] << nil
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_2 += 1
          col_ft_merge += 1
          
          footer_2[:columns] << nil
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_2 += 1
          col_ft_merge += 1
          
          footer_2[:columns] << nil
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_2 += 1
          col_ft_merge += 1
          
          if params[:doctor_col].present?
            footer_2[:columns] << nil
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_2 += 1
            col_ft_merge += 1
          end
          
          if params[:patient_col].present?
            footer_2[:columns] << nil
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_2 += 1
            col_ft_merge += 1
          end
          
          if params[:patient_state_col].present?
            footer_2[:columns] << nil
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_2 += 1
            col_ft_merge += 1
          end
          
          if params[:product_state_col].present?
            footer_2[:columns] << nil
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_2 += 1
            col_ft_merge += 1
          end
          
          if params[:warehouse_col].present?
            footer_2[:columns] << nil
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
            col_ft_2 += 1
            col_ft_merge += 1
          end
          
          footer_2[:columns] << nil
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_2 += 1
          col_ft_merge += 1
          
          footer_2[:columns] << @product_returns.total_delivery_quantity #"=SUM(#{('A'.codepoints.first + qty).chr}#{delivery_num_row_first}:#{('A'.codepoints.first + qty).chr}#{num_row})"
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_center).deep_merge(border))
          col_ft_2 += 1
          
          footer_2[:columns] << nil
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_2 += 1
          
          if params[:return_discount_col].present?
            footer_2[:columns] << @product_returns.discount #@product_returns.discount#"=SUM(#{('A'.codepoints.first + giamgia).chr}#{delivery_num_row_first}:#{('A'.codepoints.first + giamgia).chr}#{num_row})"
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
            col_ft_2 += 1
          end
          
          if params[:return_total_without_tax_col].present?
            #footer_2[:columns] << @product_returns.ordered_subtotal #@product_returns.ordered_subtotal#"=SUM(#{('A'.codepoints.first + thanhtien).chr}#{delivery_num_row_first}:#{('A'.codepoints.first + thanhtien).chr}#{num_row})"
            footer_2[:columns] << @product_returns.total_without_tax
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
            col_ft_2 += 1
          end
          
          if params[:return_tax_col].present?
            footer_2[:columns] << @product_returns.tax_amount
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
            col_ft_2 += 1
          end
          
          if params[:return_total_col].present?
            #footer_2[:columns] << @product_returns.cache_total_amount #"=SUM(#{('A'.codepoints.first + tongcong).chr}#{delivery_num_row_first}:#{('A'.codepoints.first + tongcong).chr}#{num_row})"
            footer_2[:columns] << @product_returns.total
            footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
            col_ft_2 += 1
          end
          col_amount_ft_2 = col_ft_2
          
          footer_2[:columns] << nil
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(border))
          
          footer_2[:columns] << nil
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(border))
          
          sheet.add_row footer_2[:columns], style: footer_2[:styles]
          num_row += 1
          row_ft_2 = num_row
          # Merge total colunm
          sheet.merge_cells("#{('A'.codepoints.first).chr}#{num_row}:#{('A'.codepoints.first + col_ft_merge).chr}#{num_row}")
          # Merge note colunm
          sheet.merge_cells("#{('A'.codepoints.first + col_note1).chr}#{num_row}:#{('A'.codepoints.first + col_note2).chr}#{num_row}")
        end
        
        
        # ############################ Chi tiết thanh toán ############################
        
        # add empty row
        sheet.add_row [nil]
        num_row += 1
        sheet.add_row ['3. Chi tiết thanh toán'], b: true
        num_row += 1
        
        if @payment_records.count > 0
          # header_3
          header_3 = {columns: [], styles: []}
          footer_3 = {columns: [], styles: []}
          
          header_3[:columns] << 'Ngày chứng từ'
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c = 0
          
          header_3[:columns] << 'Số chứng từ'
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          
          header_3[:columns] << 'Diễn giải'
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          col_dien_giai_first = c
          
          header_3[:columns] << nil
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          
          header_3[:columns] << nil
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          col_dien_giai_last = c
          sheet.merge_cells("#{('A'.codepoints.first + col_dien_giai_first).chr}#{num_row+1}:#{('A'.codepoints.first + col_dien_giai_last).chr}#{num_row+1}")
          
          header_3[:columns] << 'Loại thanh toán'
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          
          header_3[:columns] << 'Số tiền'
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          col_so_tien_first = c
          
          header_3[:columns] << nil
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          col_so_tien_last = c
          sheet.merge_cells("#{('A'.codepoints.first + col_so_tien_first).chr}#{num_row+1}:#{('A'.codepoints.first + col_so_tien_last).chr}#{num_row+1}")
          
          header_3[:columns] << 'Ghi chú'
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          col_note1 = c
          
          header_3[:columns] << nil
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          
          header_3[:columns] << nil
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          
          header_3[:columns] << nil
          header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          col_note2 = c
          sheet.merge_cells("#{('A'.codepoints.first + col_note1).chr}#{num_row+1}:#{('A'.codepoints.first + col_note2).chr}#{num_row+1}")
          
          sheet.add_row header_3[:columns], style: header_3[:styles]
          num_row += 1
          
          # rows //Payment records
          @payment_records.each do |payment_record|
            row_3 = {columns: [], styles: []}
            
            row_3[:columns] << payment_record.payment_date
            row_3[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(date_format).deep_merge(bold))
            
            row_3[:columns] << payment_record.code
            row_3[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bold))
            
            row_3[:columns] << payment_record.get_report_name
            row_3[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bold))
            
            row_3[:columns] << nil
            row_3[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bold))
            
            row_3[:columns] << nil
            row_3[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bold))
            
            row_3[:columns] << t(".#{payment_record.payment_type_code}")
            row_3[:styles] << (s.add_style text_left.deep_merge(border))
            
            row_3[:columns] << payment_record.amount
            row_3[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
            
            row_3[:columns] << nil
            row_3[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
            
            row_3[:columns] << payment_record.description
            row_3[:styles] << (s.add_style text_left.deep_merge(border))
            
            row_3[:columns] << nil
            row_3[:styles] << (s.add_style text_left.deep_merge(border))
            
            row_3[:columns] << nil
            row_3[:styles] << (s.add_style text_left.deep_merge(border))
            
            row_3[:columns] << nil
            row_3[:styles] << (s.add_style text_left.deep_merge(border))
            
            sheet.add_row row_3[:columns], style: row_3[:styles]
            num_row += 1
            
            sheet.merge_cells("#{('A'.codepoints.first + col_dien_giai_first).chr}#{num_row}:#{('A'.codepoints.first + col_dien_giai_last).chr}#{num_row}")
            sheet.merge_cells("#{('A'.codepoints.first + col_so_tien_first).chr}#{num_row}:#{('A'.codepoints.first + col_so_tien_last).chr}#{num_row}")
            sheet.merge_cells("#{('A'.codepoints.first + col_note1).chr}#{num_row}:#{('A'.codepoints.first + col_note2).chr}#{num_row}")
          end
          
          # footer
          footer_3[:columns] << 'Tổng cộng'
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(wrap_text).deep_merge(border))
          col_ft_3 = 0
          col_ft_merge = 0
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_3 += 1
          col_ft_merge += 1
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_3 += 1
          col_ft_merge += 1
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_3 += 1
          col_ft_merge += 1
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_3 += 1
          col_ft_merge += 1
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_3 += 1
          col_ft_merge += 1
          
          footer_3[:columns] << @customer.sales_paid_amount(from_date: @from, to_date: @to)
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_3 += 1
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(border))
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(border))
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(border))
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(border))
          
          footer_3[:columns] << nil
          footer_3[:styles] << (s.add_style bg_footer.deep_merge(border))
          
          sheet.add_row footer_3[:columns], style: footer_3[:styles]
          num_row += 1
          row_ft_3 = num_row
          
          # Merge total colunm
          sheet.merge_cells("#{('A'.codepoints.first).chr}#{num_row}:#{('A'.codepoints.first + col_ft_merge).chr}#{num_row}")
          
          # Merge amount colunm
          sheet.merge_cells("#{('A'.codepoints.first + col_so_tien_first).chr}#{num_row}:#{('A'.codepoints.first + col_so_tien_last).chr}#{num_row}")
          
          # Merge note colunm
          sheet.merge_cells("#{('A'.codepoints.first + col_note1).chr}#{num_row}:#{('A'.codepoints.first + col_note2).chr}#{num_row}")
        end
        
        
        # ############################ 4. Tổng kết ############################
        
        add_patient_num = (params[:doctor_col].present? ? 1 : 0) +
                          (params[:patient_col].present? ? 1 : 0) +
                          (params[:patient_state_col].present? ? 1 : 0) +
                          (params[:product_state_col].present? ? 1 : 0) +
                          (params[:warehouse_col].present? ? 1 : 0)
        
        # add empty row
        sheet.add_row [nil]
        num_row += 1
        sheet.add_row ['4. Tổng kết'], b: true
        num_row += 1
        
        # header_4
        header_4 = {columns: [], styles: []}
        
        header_4[:columns] << 'Số TT'
        header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_4[:columns] << 'Diễn giải'
        header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_4[:columns] << nil
        header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_4[:columns] << nil
        header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        if params[:doctor_col].present?
          header_4[:columns] << nil
          header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        end
        
        if params[:patient_col].present?
          header_4[:columns] << nil
          header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        end
        
        if params[:patient_state_col].present?
          header_4[:columns] << nil
          header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        end
        
        if params[:product_state_col].present?
          header_4[:columns] << nil
          header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        end
        
        if params[:warehouse_col].present?
          header_4[:columns] << nil
          header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        end
        
        header_4[:columns] << nil #dvt
        header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_4[:columns] << nil #sluong
        header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_4[:columns] << 'Số tiền'
        header_4[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        sheet.add_row header_4[:columns], style: header_4[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5 + add_patient_num).chr}#{num_row}")
        
        # Add rows
        rw1 = {columns: [], styles: []}
        rw2 = {columns: [], styles: []}
        rw3 = {columns: [], styles: []}
        rw4 = {columns: [], styles: []}
        rw5 = {columns: [], styles: []}
        rw6 = {columns: [], styles: []}
        
        rw1[:columns] << '1'
        rw1[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_1 = num_row + 1
        rw2[:columns] << '2'
        rw2[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_2 = num_row + 2
        rw3[:columns] << '3'
        rw3[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_3 = num_row + 3
        rw4[:columns] << '4'
        rw4[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_4 = num_row + 4
        rw5[:columns] << '5'
        rw5[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_5 = num_row + 5
        rw6[:columns] << '6'
        rw6[:styles] << (s.add_style bg_footer.deep_merge(text_center).deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_6 = num_row + 6
        num_col = 0
        
        rw1[:columns] << 'Tổng tiền còn phải thanh toán của kỳ trước:'
        rw1[:styles] << (s.add_style text_left.deep_merge(bold).deep_merge(border_dotted_bottom))
        rw2[:columns] << 'Tổng tiền hàng bán trong kỳ:'
        rw2[:styles] << (s.add_style text_left.deep_merge(italic).deep_merge(border_dotted_bottom))
        rw3[:columns] << 'Tổng tiền hàng trả lại trong kỳ:'
        rw3[:styles] << (s.add_style text_left.deep_merge(italic).deep_merge(border_dotted_bottom))
        rw4[:columns] << 'Tổng tiền phải thanh toán trong kỳ:'
        rw4[:styles] << (s.add_style text_left.deep_merge(bold).deep_merge(border_dotted_bottom))
        rw5[:columns] << 'Số tiền đã thanh toán trong kỳ:'
        rw5[:styles] << (s.add_style text_left.deep_merge(border_dotted_bottom))
        rw6[:columns] << 'Số tiền còn lại phải thanh toán:'
        rw6[:styles] << (s.add_style bg_footer.deep_merge(text_left).deep_merge(bold).deep_merge(border_dotted_bottom))
        num_col += 1
        
        (num_col..(num_col+3+add_patient_num)).each do |c|
          num_col += 1
          rw1[:columns] << nil
          rw1[:styles] << (s.add_style border_dotted_bottom)
          rw2[:columns] << nil
          rw2[:styles] << (s.add_style border_dotted_bottom)
          rw3[:columns] << nil
          rw3[:styles] << (s.add_style border_dotted_bottom)
          rw4[:columns] << nil
          rw4[:styles] << (s.add_style border_dotted_bottom)
          rw5[:columns] << nil
          rw5[:styles] << (s.add_style border_dotted_bottom)
          rw6[:columns] << nil
          rw6[:styles] << (s.add_style border_dotted_bottom)
        end
        
        num_col += 1
        begin_sales_debt_amount = @customer.sales_debt_amount(to_date: (@from - 1.day))
        rw1[:columns] << begin_sales_debt_amount
        rw1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom).deep_merge(bold))
        
        sales_order_total_amount = @orders.sum(&:total)
        rw2[:columns] << sales_order_total_amount
        rw2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom))
        
        sales_return_total_amount = @product_returns.total
        rw3[:columns] << sales_return_total_amount
        rw3[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom))
        
        #period_amount = @customer.sales_total_amount(from_date: @from, to_date: @to)
        period_amount = sales_order_total_amount - sales_return_total_amount
        rw4[:columns] << period_amount
        rw4[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom).deep_merge(bold))
        
        sales_paid_amount = @customer.sales_paid_amount(from_date: @from, to_date: @to)
        rw5[:columns] << sales_paid_amount
        rw5[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom))
        
        #end_sales_debt_amount = @customer.sales_debt_amount(to_date: @to)
        end_sales_debt_amount = begin_sales_debt_amount + period_amount - sales_paid_amount
        rw6[:columns] << end_sales_debt_amount
        rw6[:styles] << (s.add_style bg_footer.deep_merge(text_right).deep_merge(number).deep_merge(border_dotted_bottom).deep_merge(bold))
        
        sheet.add_row rw1[:columns], style: rw1[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5 + add_patient_num).chr}#{num_row}")
        sheet.add_row rw2[:columns], style: rw2[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5 + add_patient_num).chr}#{num_row}")
        sheet.add_row rw3[:columns], style: rw3[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5 + add_patient_num).chr}#{num_row}")
        sheet.add_row rw4[:columns], style: rw4[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5 + add_patient_num).chr}#{num_row}")
        sheet.add_row rw5[:columns], style: rw5[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5 + add_patient_num).chr}#{num_row}")
        sheet.add_row rw6[:columns], style: rw6[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5 + add_patient_num).chr}#{num_row}")
        
        # ############################ Footer Signature ############################
        # add empty row
        sheet.add_row [nil]
        num_row += 1
        sheet.add_row ['5. Phần xác nhận đối chiếu công nợ:'], b: true
        num_row += 1
        
        sign = {columns: [], styles: []}
        sign1 = {columns: [], styles: []}
        sign2 = {columns: [], styles: []}
        
        # Column 1
        sign[:columns] << nil
        sign[:styles] << (s.add_style {})
        sign1[:columns] << nil
        sign1[:styles] << (s.add_style {})
        sign2[:columns] << nil
        sign2[:styles] << (s.add_style {})
        
        # Column 2
        sign[:columns] << Time.now.strftime('Ngày %d tháng %m năm %Y')
        sign[:styles] << (s.add_style text_center.merge(italic))
        sign1[:columns] << 'KẾ TOÁN - CÔNG TY TNHH ORTHO-K VIỆT NAM'
        sign1[:styles] << (s.add_style text_center.merge(bold))
        sign2[:columns] << '(Ký, họ tên)'
        sign2[:styles] << (s.add_style text_center.merge(italic))
        
        # Column 3,4
        sign[:columns] << nil
        sign[:styles] << (s.add_style {})
        sign1[:columns] << nil
        sign1[:styles] << (s.add_style {})
        sign2[:columns] << nil
        sign2[:styles] << (s.add_style {})
        
        sign[:columns] << nil
        sign[:styles] << (s.add_style {})
        sign1[:columns] << nil
        sign1[:styles] << (s.add_style {})
        sign2[:columns] << nil
        sign2[:styles] << (s.add_style {})
        
        # Column 5, 6, 7, 8, 9
        if params[:doctor_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})
          sign1[:columns] << nil
          sign1[:styles] << (s.add_style {})
          sign2[:columns] << nil
          sign2[:styles] << (s.add_style {})
        end
        if params[:patient_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})      
          sign1[:columns] << 'NHÂN VIÊN SALE PHỤ TRÁCH'
          sign1[:styles] << (s.add_style text_center.merge(bold))
          sign2[:columns] << '(Ký, họ tên)'
          sign2[:styles] << (s.add_style text_center.merge(italic))
        end
        if params[:patient_state_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})
          sign1[:columns] << nil
          sign1[:styles] << (s.add_style {})
          sign2[:columns] << nil
          sign2[:styles] << (s.add_style {})
        end
        if params[:product_state_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})
          sign1[:columns] << nil
          sign1[:styles] << (s.add_style {})
          sign2[:columns] << nil
          sign2[:styles] << (s.add_style {})
        end
        if params[:warehouse_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})
          sign1[:columns] << nil
          sign1[:styles] << (s.add_style {})
          sign2[:columns] << nil
          sign2[:styles] << (s.add_style {})
        end
        
        # Column 10,11 (ĐVT, Soluong, Dongia)
        sign[:columns] << nil
        sign[:styles] << (s.add_style {})
        sign1[:columns] << nil
        sign1[:styles] << (s.add_style {})
        sign2[:columns] << nil
        sign2[:styles] << (s.add_style {})
        
        sign[:columns] << nil
        sign[:styles] << (s.add_style {})
        sign1[:columns] << nil
        sign1[:styles] << (s.add_style {})
        sign2[:columns] << nil
        sign2[:styles] << (s.add_style {})
        
        sign[:columns] << nil
        sign[:styles] << (s.add_style {})
        sign1[:columns] << nil
        sign1[:styles] << (s.add_style {})
        sign2[:columns] << nil
        sign2[:styles] << (s.add_style {})
        
        # Column 12, 13, 14, 15 (GG, TT, Thuế, T.cộng)
        if params[:sales_discount_col].present? or params[:return_discount_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})
          sign1[:columns] << nil
          sign1[:styles] << (s.add_style {})
          sign2[:columns] << nil
          sign2[:styles] << (s.add_style {})
        end
        if params[:sales_total_without_tax_col].present? or params[:return_total_without_tax_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})
          sign1[:columns] << nil
          sign1[:styles] << (s.add_style {})
          sign2[:columns] << nil
          sign2[:styles] << (s.add_style {})
        end
        if params[:sales_tax_col].present? or params[:return_tax_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})
          sign1[:columns] << nil
          sign1[:styles] << (s.add_style {})
          sign2[:columns] << nil
          sign2[:styles] << (s.add_style {})
        end
        if params[:sales_total_col].present? or params[:return_total_col].present?
          sign[:columns] << nil
          sign[:styles] << (s.add_style {})
          sign1[:columns] << nil
          sign1[:styles] << (s.add_style {})
          sign2[:columns] << nil
          sign2[:styles] << (s.add_style {})
        end
        
        sign[:columns] << nil
        sign[:styles] << (s.add_style {})
        sign1[:columns] << "KHÁCH HÀNG - #{@customer.name}"
        sign1[:styles] << (s.add_style text_center.merge(bold))
        sign2[:columns] << '(Ký, họ tên)'
        sign2[:styles] << (s.add_style text_center.merge(italic))
        
        sheet.add_row sign[:columns], style: sign[:styles]
        num_row += 1
        sheet.add_row sign1[:columns], style: sign1[:styles]
        num_row += 1
        sheet.add_row sign2[:columns], style: sign2[:styles]
        num_row += 1
        
        patient_col_widths = []
        if params[:patient_col].present?
          patient_col_widths << 10
        end
        if params[:patient_state_col].present?
          patient_col_widths << 10
        end
        
        price_col_widths = []
        if params[:return_total_without_tax_col].present? or params[:sales_total_without_tax_col].present?
          price_col_widths << 12
        end
        if params[:return_discount_col].present? or params[:sales_discount_col].present?
          price_col_widths << 12
        end
        if params[:return_total_col].present? or params[:sales_total_col].present?
          price_col_widths << 12
        end
        if params[:return_tax_col].present? or params[:sales_tax_col].present?
          price_col_widths << 12
        end
        
        # Setup
        sheet.merge_cells("#{('A'.codepoints.first).chr}4:#{('A'.codepoints.first + (c.to_i)).chr}4")
        sheet.merge_cells("#{('A'.codepoints.first).chr}5:#{('A'.codepoints.first + (c.to_i)).chr}5")
        sheet.merge_cells("#{('A'.codepoints.first).chr}6:#{('A'.codepoints.first + (c.to_i)).chr}6")
        sheet.column_widths *column_widths
      end
    end
    
    xlsx_package.serialize (tmp_path + file_name)
  end
end