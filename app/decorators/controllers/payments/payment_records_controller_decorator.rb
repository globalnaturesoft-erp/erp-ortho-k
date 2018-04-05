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
    glb = params.to_unsafe_hash[:global_filter]
    if glb[:period].present?
      @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
      @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
    else
      @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
      @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
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
    if params.to_unsafe_hash["filters"].present?
      params.to_unsafe_hash["filters"].each do |ft|
        ft[1].each do |cond|
          if cond[1]["name"] == 'in_period_active'
            @customers = @customers.get_sales_payment_chasing_contacts(
              from_date: @from,
              to_date: @to
            )
          end
        end
      end
    end
    
    @full_customers = @customers
    
    # create files
    tmp_path = "tmp/#{Time.now.to_i}/"
    Dir.mkdir(tmp_path) unless File.exists?(tmp_path)
    
    @customers.each do |customer|
      file_name = "#{customer.name.to_ascii.gsub(/\s+/,'_')}-#{customer.id}.xls"
      create_xlsx_files(customer, glb, tmp_path, file_name)
    end
    
    # zip files
    temp = Tempfile.new 'cong_no.zip'
    Zip::File.open(temp.path, Zip::File::CREATE) do |zipfile|
      @customers.each do |customer|
        file_name = "#{customer.name.to_ascii.gsub(/\s+/,'_')}-#{customer.id}.xls"
        zipfile.add file_name, tmp_path + file_name
      end
    end

    send_file temp.path, type: "application/zip", x_sendfile: true,
      disposition: "attachment", filename: "ChiTietCongNo.zip"
  end
  
  def create_xlsx_files(customer, glb, tmp_path, file_name)
    if glb[:period].present?
      @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
      @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
    else
      @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
      @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
    end

    @customer = customer
    @orders = @customer.sales_orders.payment_for_contact_orders(glb)
    @product_returns = @customer.sales_product_returns.get_deliveries_with_payment_for_contact(glb)
    
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
          date = "#{' NGÀY ' + @from.to_date.strftime('%d/%m/%Y')}"
        else
          date = "#{' TỪ ' + @from.to_date.strftime('%d/%m/%Y') if !@from.nil?}#{' ĐẾN ' + @to.to_date.strftime('%d/%m/%Y') if !@to.nil?}"
        end
        
        # Top head
        sheet.add_row ["CÔNG TY TNHH ORTHO-K VIỆT NAM"], b: true
        sheet.add_row ["535 An Dương Vương, Phường 8, Quận 5, TP. Hồ Chí Minh, Việt Nam"], b: true
        
        sheet.add_row ['BẢNG CHI TIẾT CÔNG NỢ' + date], sz: 16, b: true, bg_color: "ffc801", style: (s.add_style text_center)
        
        num_row = 3
        
        # ############################ Chi tiết bán hàng ############################
        
        # add empty row
        sheet.add_row ['']
        num_row += 1
        sheet.add_row ['1. Chi tiết bán hàng'], b: true
        num_row += 1
        
        if @orders.count > 0
          # header_1
          header_1 = {columns: [], styles: []}
          subheader_1 = {columns: [], styles: []}
          footer_1 = {columns: [], styles: []}
          
          header_1[:columns] << 'Ngày chứng từ'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << ''
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c = 0
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_1[:columns] << 'Số chứng từ'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << ''
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_1[:columns] << 'Diễn giải'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << ''
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_1[:columns] << 'Kho'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << ''
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_1[:columns] << 'ĐVT'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << ''
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_1[:columns] << 'Số lượng'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << ''
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          qty = c
          
          header_1[:columns] << 'Doanh thu'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))    
          subheader_1[:columns] << 'Đơn giá'
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + (c+2)).chr}#{num_row+1}")
          pri = c
          
          header_1[:columns] << ''
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << 'Giảm giá'
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          dis = c
          
          header_1[:columns] << ''
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << 'Thành tiền'
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          amo = c
          
          header_1[:columns] << 'Ghi chú'
          header_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_1[:columns] << ''
          subheader_1[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          sheet.add_row header_1[:columns], style: header_1[:styles]
          num_row += 1
          sheet.add_row subheader_1[:columns], style: subheader_1[:styles]
          num_row += 1
          
          order_num_row_first = num_row + 1
          # rows //Sales orders
          @orders.each do |order|
            row_1 = {columns: [], styles: []}
            
            row_1[:columns] << order.order_date
            row_1[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(date_format).deep_merge(bold))
            
            row_1[:columns] << order.code
            row_1[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bold))
            
            row_1[:columns] << order.get_report_name
            row_1[:styles] << (s.add_style border.deep_merge(bold))
            
            row_1[:columns] << ''
            row_1[:styles] << (s.add_style border)
            
            row_1[:columns] << ''
            row_1[:styles] << (s.add_style border)
            
            row_1[:columns] << ''
            row_1[:styles] << (s.add_style border)
            
            row_1[:columns] << ''
            row_1[:styles] << (s.add_style border)
            
            row_1[:columns] << ''
            row_1[:styles] << (s.add_style border)
            
            row_1[:columns] << ''
            row_1[:styles] << (s.add_style border)
            
            row_1[:columns] << ''
            row_1[:styles] << (s.add_style border)
            
            sheet.add_row row_1[:columns], style: row_1[:styles]
            num_row += 1
            
            order.order_details.each_with_index do |order_detail|
              row_1 = {columns: [], styles: []}
              
              row_1[:columns] << ''
              row_1[:styles] << (s.add_style text_center.deep_merge(border))
              
              row_1[:columns] << ''
              row_1[:styles] << (s.add_style text_left.deep_merge(border))
              
              row_1[:columns] << order_detail.product_name
              row_1[:styles] << (s.add_style text_left.deep_merge(border))
              
              row_1[:columns] << order_detail.order.warehouse_name
              row_1[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_1[:columns] << order_detail.product_unit_name
              row_1[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_1[:columns] << order_detail.quantity
              row_1[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_1[:columns] << order_detail.price
              row_1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              
              row_1[:columns] << order_detail.discount_amount
              row_1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              
              row_1[:columns] << order_detail.total
              row_1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              
              row_1[:columns] << order_detail.description
              row_1[:styles] << (s.add_style text_center.deep_merge(border))
              
              sheet.add_row row_1[:columns], style: row_1[:styles]
              num_row += 1
            end
          end
          
          # footer
          footer_1[:columns] << 'Tổng cộng'
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(wrap_text).deep_merge(border))
          col_ft_1 = 0
          
          footer_1[:columns] << ''
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_1 += 1
          
          footer_1[:columns] << ''
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_1 += 1
          
          footer_1[:columns] << ''
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_1 += 1
          
          footer_1[:columns] << ''
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_1 += 1
          
          footer_1[:columns] << "=SUM(#{('A'.codepoints.first + qty).chr}#{order_num_row_first}:#{('A'.codepoints.first + qty).chr}#{num_row})"
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_center).deep_merge(border))
          col_ft_1 += 1
          
          footer_1[:columns] << "=SUM(#{('A'.codepoints.first + pri).chr}#{order_num_row_first}:#{('A'.codepoints.first + pri).chr}#{num_row})"
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_1 += 1
          
          footer_1[:columns] << "=SUM(#{('A'.codepoints.first + dis).chr}#{order_num_row_first}:#{('A'.codepoints.first + dis).chr}#{num_row})"
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_1 += 1
          
          footer_1[:columns] << "=SUM(#{('A'.codepoints.first + amo).chr}#{order_num_row_first}:#{('A'.codepoints.first + amo).chr}#{num_row})"
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_1 += 1
          col_amount_ft_1 = col_ft_1
          
          footer_1[:columns] << ''
          footer_1[:styles] << (s.add_style bg_footer.deep_merge(border).deep_merge(border))
          
          sheet.add_row footer_1[:columns], style: footer_1[:styles]
          num_row += 1
          row_ft_1 = num_row
          sheet.merge_cells("#{('A'.codepoints.first).chr}#{num_row}:#{('A'.codepoints.first + 4).chr}#{num_row}")
        end
        
        
        # ############################ Chi tiết hàng trả lại ############################
        
        # add empty row
        sheet.add_row ['']
        num_row += 1
        sheet.add_row ['2. Chi tiết hàng trả lại'], b: true
        num_row += 1
        
        if @product_returns.count > 0
          # header_1
          header_2 = {columns: [], styles: []}
          subheader_2 = {columns: [], styles: []}
          footer_2 = {columns: [], styles: []}
          
          header_2[:columns] << 'Ngày chứng từ'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << ''
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c = 0
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'Số chứng từ'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << ''
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'Diễn giải'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << ''
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'Kho'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << ''
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'ĐVT'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << ''
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          header_2[:columns] << 'Số lượng'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << ''
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          qty = c
          
          header_2[:columns] << 'Doanh thu'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))    
          subheader_2[:columns] << 'Đơn giá'
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + (c+2)).chr}#{num_row+1}")
          pri = c
          
          header_2[:columns] << ''
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << 'Giảm giá'
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          dis = c
          
          header_2[:columns] << ''
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << 'Thành tiền'
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          amo = c
          
          header_2[:columns] << 'Ghi chú'
          header_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          subheader_2[:columns] << ''
          subheader_2[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
          c += 1
          sheet.merge_cells("#{('A'.codepoints.first + c).chr}#{num_row+1}:#{('A'.codepoints.first + c).chr}#{num_row+2}")
          
          sheet.add_row header_2[:columns], style: header_2[:styles]
          num_row += 1
          sheet.add_row subheader_2[:columns], style: subheader_2[:styles]
          num_row += 1
          
          delivery_num_row_first = num_row + 1
          # rows //Sales imports - Product returns
          @product_returns.each do |delivery|
            row_2 = {columns: [], styles: []}
            
            row_2[:columns] << delivery.date
            row_2[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(date_format).deep_merge(bold))
            
            row_2[:columns] << delivery.code
            row_2[:styles] << (s.add_style text_left.deep_merge(border).deep_merge(bold))
            
            row_2[:columns] << delivery.get_report_name
            row_2[:styles] << (s.add_style border.deep_merge(bold))
            
            row_2[:columns] << ''
            row_2[:styles] << (s.add_style border)
            
            row_2[:columns] << ''
            row_2[:styles] << (s.add_style border)
            
            row_2[:columns] << ''
            row_2[:styles] << (s.add_style border)
            
            row_2[:columns] << ''
            row_2[:styles] << (s.add_style border)
            
            row_2[:columns] << ''
            row_2[:styles] << (s.add_style border)
            
            row_2[:columns] << ''
            row_2[:styles] << (s.add_style border)
            
            row_2[:columns] << ''
            row_2[:styles] << (s.add_style border)
            
            sheet.add_row row_2[:columns], style: row_2[:styles]
            num_row += 1
            
            delivery.delivery_details.each_with_index do |delivery_detail|
              row_2 = {columns: [], styles: []}
              row_2[:columns] = []
              
              row_2[:columns] << ''
              row_2[:styles] << (s.add_style text_center.deep_merge(border))
              
              row_2[:columns] << ''
              row_2[:styles] << (s.add_style text_center.deep_merge(border))
              
              #rt = Axlsx::RichText.new
              #rt.add_run(delivery_detail.get_report_name, :i => true)
              row_2[:columns] << "#{delivery_detail.product_name} #{'(' + delivery_detail.get_report_name + ')' if !delivery_detail.get_report_name.empty?}"
              row_2[:styles] << (s.add_style text_left.deep_merge(border))
              
              row_2[:columns] << delivery_detail.warehouse_name
              row_2[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_2[:columns] << delivery_detail.product_unit
              row_2[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_2[:columns] << delivery_detail.quantity
              row_2[:styles] << (s.add_style text_center.deep_merge(number).deep_merge(border))
              
              row_2[:columns] << delivery_detail.price
              row_2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              
              row_2[:columns] << ''
              row_2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              
              row_2[:columns] << delivery_detail.cache_total
              row_2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border))
              
              row_2[:columns] << delivery_detail.note
              row_2[:styles] << (s.add_style text_left.deep_merge(border))
              
              sheet.add_row row_2[:columns], style: row_2[:styles]
              num_row += 1
            end
          end
          
          # footer
          footer_2[:columns] << 'Tổng cộng'
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(wrap_text).deep_merge(border))
          col_ft_2 = 0
          
          footer_2[:columns] << ''
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_2 += 1
          
          footer_2[:columns] << ''
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_2 += 1
          
          footer_2[:columns] << ''
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_2 += 1
          
          footer_2[:columns] << ''
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(bold).deep_merge(border))
          col_ft_2 += 1
          
          footer_2[:columns] << "=SUM(#{('A'.codepoints.first + qty).chr}#{delivery_num_row_first}:#{('A'.codepoints.first + qty).chr}#{num_row})"
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_center).deep_merge(border))
          col_ft_2 += 1
          
          footer_2[:columns] << "=SUM(#{('A'.codepoints.first + pri).chr}#{delivery_num_row_first}:#{('A'.codepoints.first + pri).chr}#{num_row})"
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_2 += 1
          
          footer_2[:columns] << "=SUM(#{('A'.codepoints.first + dis).chr}#{delivery_num_row_first}:#{('A'.codepoints.first + dis).chr}#{num_row})"
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_2 += 1
          
          footer_2[:columns] << "=SUM(#{('A'.codepoints.first + amo).chr}#{delivery_num_row_first}:#{('A'.codepoints.first + amo).chr}#{num_row})"
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(number).deep_merge(bold).deep_merge(text_right).deep_merge(border))
          col_ft_2 += 1
          col_amount_ft_2 = col_ft_2
          
          footer_2[:columns] << ''
          footer_2[:styles] << (s.add_style bg_footer.deep_merge(border))
          
          sheet.add_row footer_2[:columns], style: footer_2[:styles]
          num_row += 1
          row_ft_2 = num_row
          sheet.merge_cells("#{('A'.codepoints.first).chr}#{num_row}:#{('A'.codepoints.first + 4).chr}#{num_row}")
        end
        
        
        # ############################ 3. Tổng kết ############################
        
        # add empty row
        sheet.add_row ['']
        num_row += 1
        sheet.add_row ['3. Tổng kết'], b: true
        num_row += 1
        
        # header_3
        header_3 = {columns: [], styles: []}
        
        header_3[:columns] << 'Số TT'
        header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_3[:columns] << 'Diễn giải'
        header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_3[:columns] << ''
        header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_3[:columns] << ''
        header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_3[:columns] << ''
        header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_3[:columns] << ''
        header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        header_3[:columns] << 'Số tiền'
        header_3[:styles] << (s.add_style bg_info.deep_merge(wrap_text).merge(bold).deep_merge(border))
        
        sheet.add_row header_3[:columns], style: header_3[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5).chr}#{num_row}")
        
        # Add rows
        rw1 = {columns: [], styles: []}
        rw2 = {columns: [], styles: []}
        rw3 = {columns: [], styles: []}
        rw4 = {columns: [], styles: []}
        rw5 = {columns: [], styles: []}
        rw6 = {columns: [], styles: []}
        
        rw1[:columns] << '1'
        rw1[:styles] << (s.add_style text_center.deep_merge(bold).deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_1 = num_row + 1
        rw2[:columns] << '2'
        rw2[:styles] << (s.add_style text_center.deep_merge(italic).deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_2 = num_row + 2
        rw3[:columns] << '3'
        rw3[:styles] << (s.add_style text_center.deep_merge(italic).deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_3 = num_row + 3
        rw4[:columns] << '4'
        rw4[:styles] << (s.add_style text_center.deep_merge(bold).deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_4 = num_row + 4
        rw5[:columns] << '5'
        rw5[:styles] << (s.add_style text_center.deep_merge(border).deep_merge(border_dotted_bottom))
        num_row_total_5 = num_row + 5
        rw6[:columns] << '6'
        rw6[:styles] << (s.add_style bg_footer.deep_merge(text_center).deep_merge(bold).deep_merge(border).deep_merge(border_dotted_bottom))
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
        
        (num_col..(num_col+3)).each do |c|
          num_col += 1
          rw1[:columns] << ''
          rw1[:styles] << (s.add_style border_dotted_bottom)
          rw2[:columns] << ''
          rw2[:styles] << (s.add_style border_dotted_bottom)
          rw3[:columns] << ''
          rw3[:styles] << (s.add_style border_dotted_bottom)
          rw4[:columns] << ''
          rw4[:styles] << (s.add_style border_dotted_bottom)
          rw5[:columns] << ''
          rw5[:styles] << (s.add_style border_dotted_bottom)
          rw6[:columns] << ''
          rw6[:styles] << (s.add_style border_dotted_bottom)
        end
        
        num_col += 1
        begin_sales_debt_amount = @customer.sales_debt_amount(to_date: (@from - 1.day))
        rw1[:columns] << begin_sales_debt_amount
        rw1[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom).deep_merge(bold))
        
        sales_order_total_amount = @orders.sum(:cache_total)
        rw2[:columns] << sales_order_total_amount
        rw2[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom))
        
        sales_return_total_amount = @product_returns.sum(:cache_total)
        rw3[:columns] << sales_return_total_amount
        rw3[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom))
        
        period_amount = @customer.sales_total_amount(from_date: @from, to_date: @to)
        rw4[:columns] << period_amount
        rw4[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom).deep_merge(bold))
        
        sales_paid_amount = @customer.sales_paid_amount(from_date: @from, to_date: @to)
        rw5[:columns] << sales_paid_amount
        rw5[:styles] << (s.add_style text_right.deep_merge(number).deep_merge(border_dotted_bottom))
        
        end_sales_debt_amount = @customer.sales_debt_amount(to_date: @to)
        rw6[:columns] << end_sales_debt_amount
        rw6[:styles] << (s.add_style bg_footer.deep_merge(text_right).deep_merge(number).deep_merge(border_dotted_bottom).deep_merge(bold))
        
        sheet.add_row rw1[:columns], style: rw1[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5).chr}#{num_row}")
        sheet.add_row rw2[:columns], style: rw2[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5).chr}#{num_row}")
        sheet.add_row rw3[:columns], style: rw3[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5).chr}#{num_row}")
        sheet.add_row rw4[:columns], style: rw4[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5).chr}#{num_row}")
        sheet.add_row rw5[:columns], style: rw5[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5).chr}#{num_row}")
        sheet.add_row rw6[:columns], style: rw6[:styles]
        num_row += 1
        sheet.merge_cells("#{('A'.codepoints.first + 1).chr}#{num_row}:#{('A'.codepoints.first + 5).chr}#{num_row}")
        
        # Setup
        sheet.merge_cells("#{('A'.codepoints.first).chr}3:#{('A'.codepoints.first + (c - 1)).chr}3")
        sheet.column_widths 15, 15, 80, 7, 7, 10, 12, 12, 12, 25
      end
    end
    
    xlsx_package.serialize (tmp_path + file_name)
  end
end