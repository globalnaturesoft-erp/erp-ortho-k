require "yaml"

module Erp
  module OrthoK
    module Backend
      class ProductsController < Erp::Backend::BackendController
        # get matrix group
        def get_matrix_group(filter, show_virtual)
          @global_filter = filter

          # period
          @from = @global_filter[:from_date].present? ? @global_filter[:from_date].to_date : nil
          @to = @global_filter[:to_date].present? ? @global_filter[:to_date].to_date : nil
          if @global_filter[:period].present?
            @period = Erp::Periods::Period.find(@global_filter[:period])
            @from = @period.from_date
            @to = @period.to_date
          end

          # product query
          @product_query = Erp::Products::Product.get_active
          @product_query = @product_query.where(category_id: @global_filter[:categories]) if @global_filter[:categories].present?

          # get diameters
          diameter_ids = @global_filter[:diameters].present? ? @global_filter[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)
          
          # get numbers
          number_ids = @global_filter[:numbers].present? ? @global_filter[:numbers] : nil
          numbers = Erp::Products::PropertiesValue.where(id: number_ids).map(&:value)
          
          # get letter
          letter_ids = @global_filter[:letters].present? ? @global_filter[:letters] : nil
          letters = Erp::Products::PropertiesValue.where(id: letter_ids).map(&:value)
          
          # filter by diameters
          if diameter_ids.present?
            if !diameter_ids.kind_of?(Array)
              @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{diameter_ids}\",%'")
            else
              diameter_ids = (diameter_ids.reject { |c| c.empty? })
              if !diameter_ids.empty?
                qs = []
                diameter_ids.each do |x|
                  qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                end
                @product_query = @product_query.where("(#{qs.join(" OR ")})")
              end
            end
          end


          # matrix
          @matrix = []
          # total
          @summary = {
            total: 0,
            out_of_stock: 0,
            equal_1: 0,
            equal_2: 0,
            equal_3: 0,
            from_4: 0
          }

          # row 1
          @matrix[0] = []
          @matrix[0][0] = {value: ''}
          @matrix[0][1] = {value: ''}
          Erp::Products::Product.matrix_cols.each do |col|
            if !letters.present? or letters.include?(col[:letter])
              @matrix[0] << {value: col[:degree]}
            end
          end

          # row 2
          @matrix[1] = []
          @matrix[1][0] = {value: ''}
          @matrix[1][1] = {value: ''}
          Erp::Products::Product.matrix_cols.each do |col|
            if !letters.present? or letters.include?(col[:letter])
              @matrix[1] << {value: col[:letter]}
            end
          end

          so_p = Erp::Products::Property.get_number
          chu_p = Erp::Products::Property.get_letter

          # rows and cols
          row_i = 0
          Erp::Products::Product.matrix_rows.each_with_index do |row, index|
            if !numbers.present? or numbers.include?(row[:number])
              row_index = row_i + 2
              row_i += 1
              
              @matrix[row_index] = []
  
              @matrix[row_index][0] = {value: row[:degree_k]}
              @matrix[row_index][1] = {value: row[:number]}
  
              Erp::Products::Product.matrix_cols.each do |col|
                if !letters.present? or letters.include?(col[:letter])
                  chu_pv = Erp::Products::PropertiesValue.where(property_id: chu_p.id, value: col[:letter]).first
                  so_pv = Erp::Products::PropertiesValue.where(property_id: so_p.id, value: row[:number]).first
    
                  product_ids = @product_query.find_by_properties_value_ids([chu_pv.id,so_pv.id]).select('id')
                  product_ids = -1 if product_ids.count == 0
                  filters = @global_filter.clone.merge({
                    product_id: product_ids,
                    state_ids: @global_filter[:states],
                    warehouse_ids: @global_filter[:warehouses]
                  })
                  if show_virtual
                    stock = Erp::Products::Product.get_stock_virtual(filters)
                  else
                    stock = Erp::Products::Product.get_stock_real(filters)
                  end
    
                  @matrix[row_index] << {
                    value: stock,
                    url_data: {
                      properties_value_ids: [chu_pv.id,so_pv.id],
                      categories: @global_filter[:categories],
                      warehouse_ids: @global_filter[:warehouses],
                      state_ids: @global_filter[:states],
                      diameters: @global_filter[:diameters]
                    }
                  }
    
                  # sumary
                  @summary[:total] += stock
    
                  if stock <= 0
                    @summary[:out_of_stock] += 1
                  elsif stock == 1
                    @summary[:equal_1] += 1
                  elsif stock == 2
                    @summary[:equal_2] += 1
                  elsif stock == 3
                    @summary[:equal_3] += 1
                  elsif stock >= 4
                    @summary[:from_4] += 1
                  end
                  
                end
              end
            end
          end

          return {filter: @global_filter, matrix: @matrix, summary: @summary}
        end

        # Matrix report
        def matrix_report
        end

        def matrix_report_table
          @matrixes = []
          
          # show virtual
          show_virtual = false
          if params.to_unsafe_hash["filters"].present?
            params.to_unsafe_hash["filters"].each do |ft|
              ft[1].each do |cond|
                # in case filter is show archived
                if cond[1]["name"] == 'show_virtual'
                  # show archived items
                  show_virtual = true
                end
              end
            end
          end

          filters = params.to_unsafe_hash[:global_filter][:filters]
          filters.each do |m|
            @matrixes << self.get_matrix_group(m[1], show_virtual)
          end

          File.open("tmp/matrix_report.yml", "w+") do |f|
            f.write(@matrixes.to_yaml)
          end

          render layout: nil
        end

        def matrix_report_xlsx
          @matrixes = YAML.load_file("tmp/matrix_report.yml")

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=Ma_tran_ton_kho_tong_hop.xlsx"
            }
          end
        end

        def tooltip_warehouse_info
          @global_filter = params.to_unsafe_hash

          # product query
          @product_query = Erp::Products::Product.get_active
          @product_query = @product_query.where(category_id: @global_filter[:categories]) if @global_filter[:categories].present?

          # get diameters
          diameter_ids = @global_filter[:diameters].present? ? @global_filter[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)
          # filter by diameters
          if diameter_ids.present?
            if !diameter_ids.kind_of?(Array)
              @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{diameter_ids}\",%'")
            else
              diameter_ids = (diameter_ids.reject { |c| c.empty? })
              if !diameter_ids.empty?
                qs = []
                diameter_ids.each do |x|
                  qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                end
                @product_query = @product_query.where("(#{qs.join(" OR ")})")
              end
            end
          end

          render layout: nil
        end

        # Delivery report
        def delivery_report
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day
        end

        # Delivery report
        def delivery_report_by_cate_diameter
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day
        end

        def delivery_report_table
          # group bys
          @global_filters = params.to_unsafe_hash[:global_filter]

          @group_by_category = (@global_filters.present? and @global_filters[:group_by_category].present?) ? @global_filters[:group_by_category] : nil
          @group_by_property = (@global_filters.present? and @global_filters[:group_by_property].present?) ? @global_filters[:group_by_property] : nil

          @properties_value_ids = (@global_filters.present? and @global_filters[:properties_values].present?) ? @global_filters[:properties_values] : nil

          if @group_by_property.present?
            @properties_values = Erp::Products::PropertiesValue.where(property_id: @group_by_property).order('value')
            if @properties_value_ids.present?
              @properties_values = @properties_values.where(id: @properties_value_ids)
            end
          end

          @products_query = Erp::Products::Product.get_active.search(params).delivery_report(filters: @global_filters)

          if @group_by_category.present?
            @categories = @group_by_category == 'all' ? Erp::Products::Category.order('name') : Erp::Products::Category.where(id: @group_by_category)

            # IF GROUP BY CATEGORY
            if @group_by_category != 'all'
              @products_query = @products_query.where(category_id: @group_by_category)
            end
          end

          @products = @products_query.order("code").paginate(:page => params[:page], :per_page => 50)

          render layout: nil
        end

        # Warehouses report
        def warehouses_report
        end

        def warehouses_report_table
          # group bys
          global_filters = params.to_unsafe_hash[:global_filter]

          @group_by_category = (global_filters.present? and global_filters[:group_by_category].present?) ? global_filters[:group_by_category] : nil
          @group_by_property = (global_filters.present? and global_filters[:group_by_property].present?) ? global_filters[:group_by_property] : nil

          @properties_value_ids = (global_filters.present? and global_filters[:properties_values].present?) ? global_filters[:properties_values] : nil

          if @group_by_property.present?
            @properties_values = Erp::Products::PropertiesValue.where(property_id: @group_by_property).order('value')
            if @properties_value_ids.present?
              @properties_values = @properties_values.where(id: @properties_value_ids)
            end
          end

          @global_filters = global_filters
          @products_query = Erp::Products::Product.orthok_filters(filters: global_filters)

          if @group_by_category.present?
            @categories = @group_by_category == 'all' ? Erp::Products::Category.order('name') : Erp::Products::Category.where(id: @group_by_category)

            # IF GROUP BY CATEGORY
            if @group_by_category != 'all'
              @products_query = @products_query.where(category_id: @group_by_category)
            end
          end

          @products = @products_query.order("ordered_code").paginate(:page => params[:page], :per_page => 50)
          @warehouses = Erp::Warehouses::Warehouse.all.order("name")

          render layout: nil
        end

        # Stock importing
        def stock_importing
        end

        def stock_importing_table
          global_filters = params.to_unsafe_hash[:global_filter]

          @warehouses = Erp::Warehouses::Warehouse.where(id: global_filters[:warehouses])
          
          @state_id = global_filters[:state].present? ? global_filters[:state] : nil
          @warehouse_ids = global_filters[:warehouses].present? ? global_filters[:warehouses] : nil

          if @warehouses.present?
            @stock_condition = (global_filters.present? and global_filters[:stock_condition].present? ? global_filters[:stock_condition].to_i : 0)
            @side_quantity = (global_filters.present? and global_filters[:side_quantity].present? ? global_filters[:side_quantity].to_i : 0)
            @central_quantity = (global_filters.present? and global_filters[:central_quantity].present? ? global_filters[:central_quantity].to_i : 0)

            @products = Erp::Products::Product.get_stock_importing_product(
              filters: global_filters,
              warehouses: global_filters[:warehouses],
              state: global_filters[:state],
              stock_condition: @stock_condition,
            )

            @area = (global_filters.present? and global_filters[:area].present? ? global_filters[:area] : nil)
          end

          render layout: nil
        end

        # Stock importing
        def stock_transfering
        end

        def stock_transfering_table
          global_filters = params.to_unsafe_hash[:global_filter]

          @from_warehouse = global_filters[:from_warehouse].present? ? Erp::Warehouses::Warehouse.find(global_filters[:from_warehouse]) : nil
          @to_warehouse = global_filters[:to_warehouse].present? ? Erp::Warehouses::Warehouse.find(global_filters[:to_warehouse]) : nil
          @state = global_filters[:state].present? ? Erp::Products::State.find(global_filters[:state]) : nil
          @transfer_quantity = global_filters[:transfer_quantity]

          @condition = global_filters[:condition]
          @condition_value = global_filters[:condition_value]

          # get categories
          category_ids = global_filters[:categories].present? ? global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = global_filters[:diameters].present? ? global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # get diameters
          letter_ids = global_filters[:letters].present? ? global_filters[:letters] : nil
          @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

          # get numbers
          number_ids = global_filters[:numbers].present? ? global_filters[:numbers] : nil
          @numbers = Erp::Products::PropertiesValue.where(id: number_ids)

          # query
          @product_query = Erp::Products::Product.get_active
          @product_query = @product_query.where(category_id: category_ids) if category_ids.present?
          # filter by diameters
          if diameter_ids.present?
            if !diameter_ids.kind_of?(Array)
              @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{diameter_ids}\",%'")
            else
              diameter_ids = (diameter_ids.reject { |c| c.empty? })
              if !diameter_ids.empty?
                qs = []
                diameter_ids.each do |x|
                  qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                end
                @product_query = @product_query.where("(#{qs.join(" OR ")})")
              end
            end
          end
          # filter by letters
          if letter_ids.present?
            if !letter_ids.kind_of?(Array)
              @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{letter_ids}\",%'")
            else
              letter_ids = (letter_ids.reject { |c| c.empty? })
              if !letter_ids.empty?
                qs = []
                letter_ids.each do |x|
                  qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                end
                @product_query = @product_query.where("(#{qs.join(" OR ")})")
              end
            end
          end
          # filter by numbers
          if number_ids.present?
            if !number_ids.kind_of?(Array)
              @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{number_ids}\",%'")
            else
              number_ids = (number_ids.reject { |c| c.empty? })
              if !number_ids.empty?
                qs = []
                number_ids.each do |x|
                  qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                end
                @product_query = @product_query.where("(#{qs.join(" OR ")})")
              end
            end
          end

          if @to_warehouse.present? and @from_warehouse.present? and @state.present? and @categories.present?
            if @condition == 'to_required'
              @product_query = @product_query.where("cache_stock <= ?", @condition_value)
            elsif @condition == 'from_redundant'
              @product_query = @product_query.where("cache_stock >= ?", @condition_value)
            end
          end



          @products = @product_query

          render layout: nil
        end

        # Import - export report
        def import_export_report
        end

        def import_export_report_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          @group_by = @global_filters[:group_by]

          if @from_date.present? and @to_date.present?
            if @group_by.present? and !@group_by.include?(Erp::Products::Product::GROUPED_BY_DEFAULT)
              @groups = Erp::Products::Product.group_import_export(@global_filters)[:groups]
              @totals = Erp::Products::Product.group_import_export(@global_filters)[:totals]
            else
              @rows = Erp::Products::Product.import_export_report(@global_filters)[:data].sort_by { |n| n[:voucher_date] }.reverse!
              @totals = Erp::Products::Product.import_export_report(@global_filters)[:total]
            end
          end
          
          File.open("tmp/import_export_report_table.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period: @period,
              from_date: @from_date,
              to_date: @to_date,
              group_by: @group_by,
              groups: @groups,
              totals: @totals,
              rows: @rows
            }.to_yaml)
          end

          render layout: nil
        end

        def import_export_report_xlsx
          data = YAML.load_file("tmp/import_export_report_table.yml")
          
          @global_filters = data[:global_filters]
          @period = data[:period]     
          @from_date = data[:from_date]
          @to_date = data[:to_date]
          @group_by = data[:group_by]
          @groups = data[:groups]
          @totals = data[:totals]
          @rows = data[:rows]

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="So chi tiet xuat nhap kho.xlsx"'
            }
          end
        end

        # Export report
        def export_report
        end

        def export_report_table
          @rows = Erp::Products::Product.export_report(params)

          render layout: nil
        end

        # Import from excel
        def import
          if request.post?
            # preview or get from tmp
            if params[:import_file].present?
              file = params[:import_file]

              File.open(Rails.root.join('tmp', 'product_import_list.xlsx'), 'wb') do |f|
                f.write(file.read)
              end
            else
              file = File.open(Rails.root.join('tmp', 'product_import_list.xlsx'))
            end

            spreadsheet = Roo::Spreadsheet.open(file.path)
            header = spreadsheet.row(1)

            # Products
            @products = []
            (2..spreadsheet.last_row).each do |i|
              row = Hash[[header, spreadsheet.row(i)].transpose]

              # data raw
              data = {
                name: row["Tên hàng"].to_s.strip,
                category: row["Loại"].to_s.strip.downcase,
                diameter: row["Đường kính"].to_s.strip.downcase,
                letter: row["Chữ"].to_s.strip,
                degree: row["Độ"].to_s.strip.downcase,
                number: (row["Số"].to_s.strip.downcase.present? ? row["Số"].to_s.strip.downcase.rjust(2, '0') : ''),
                degree_k: row["Độ K"].to_s.strip.downcase,
                unit: row["Đơn vị"].to_s.strip.downcase,
                is_outside: (row["Ngoài bảng"].to_s.strip.downcase == 'có' ? true : false),
              }

              # logs
              errors = []
              warnings = []

              # category
              category = Erp::Products::Category.where("LOWER(name) = ?", data[:category]).first
              if category.present?
              else
                errors << "Không tìm thấy chuyên mục"
              end

              # diameter
              diameter_p = Erp::Products::Property.get_diameter
              diameter_pv = Erp::Products::PropertiesValue
                .where(property_id: diameter_p.id)
                .where("LOWER(value) = ?", data[:diameter]).first
              if diameter_pv.present?
                # product.category = category
              else
                warnings << "Không tìm thấy đường kính"
              end

              # letter
              letter_p = Erp::Products::Property.get_letter
              letter_pv = Erp::Products::PropertiesValue
                .where(property_id: letter_p.id)
                .where("value = ?", data[:letter]).first
              if letter_pv.present?
                # product.category = category
              else
                warnings << "Không tìm thấy chữ"
              end

              # number
              number_p = Erp::Products::Property.get_number
              number_pv = Erp::Products::PropertiesValue
                .where(property_id: number_p.id)
                .where("LOWER(value) = ?", data[:number]).first
              if number_pv.present?
                # product.category = category
              else
                warnings << "Không tìm thấy số"
              end

              # degree
              degree_p = Erp::Products::Property.get_degree
              degree_pv = Erp::Products::PropertiesValue
                .where(property_id: degree_p.id)
                .where("LOWER(value) = ?", data[:degree]).first
              if degree_pv.present?
                # product.category = category
              else
                warnings << "Không tìm thấy độ"
              end

              # degree_k
              degree_k_p = Erp::Products::Property.get_degree_k
              degree_k_pv = Erp::Products::PropertiesValue
                .where(property_id: degree_k_p.id)
                .where("LOWER(value) = ?", data[:degree_k]).first
              if degree_k_pv.present?
                # product.category = category
              else
                warnings << "Không tìm thấy độ k"
              end

              # unit
              unit = Erp::Products::Unit
                .where("LOWER(name) = ?", data[:unit]).first
              if unit.present?
                # product.category = category
              else
                errors << "Không tìm thấy đơn vị"
              end

              names = [
                data[:name]
              ]

              if diameter_pv.present? and letter_pv.present? and number_pv.present? and category.present?
                names << "#{letter_pv.value}#{number_pv.value}-#{diameter_pv.value}-#{category.name}"
                data[:name] = "#{letter_pv.value}#{number_pv.value}-#{diameter_pv.value}-#{category.name}"
              end

              # Name check
              errors << "Không tạo được tên hàng" if !data[:name].present?

              # check exist
              if !Erp::Products::Product.where(name: names).empty?
                errors << "Sản phẩm trùng tên"
              end

              # save products
              if !params[:import_file].present? and errors.empty?
                # product
                product = Erp::Products::Product.new
                product.name = data[:name]
                product.category = category
                product.unit = unit
                product.creator = current_user
                product.is_outside = data[:is_outside]
                product.save

                # Create if not exist
                if !letter_pv.present?
                  letter_pv = Erp::Products::PropertiesValue.create(
                    property_id: letter_p.id,
                    value: data[:letter]
                  )
                end

                # properties
                Erp::Products::ProductsValue.create(
                  product_id: product.id,
                  properties_value_id: diameter_pv.id
                ) if diameter_pv.present?

                Erp::Products::ProductsValue.create(
                  product_id: product.id,
                  properties_value_id: number_pv.id
                ) if number_pv.present?

                Erp::Products::ProductsValue.create(
                  product_id: product.id,
                  properties_value_id: letter_pv.id
                ) if letter_pv.present?

                Erp::Products::ProductsValue.create(
                  product_id: product.id,
                  properties_value_id: degree_pv.id
                ) if degree_pv.present?

                Erp::Products::ProductsValue.create(
                  product_id: product.id,
                  properties_value_id: degree_k_pv.id
                ) if degree_k_pv.present?

                Erp::Products::Product.find(product.id).update_cache_properties
              end

              @products << {
                data: data,
                product: product,
                errors: errors,
                warnings: warnings,
              }

            end
          end
        end

        # Export purchasing list
        def purchasing_export

        end

        # Export purchasing list
        def purchasing_export_list
          @rows = []
          @heads = []
          @totals = {}
          @line_totals = {}
          @all_total = 0

          filters = params.to_unsafe_hash[:global_filter][:filters]
          
          # show virtual stock
          show_virtual = params.to_unsafe_hash[:global_filter][:show_virtual] == 'yes' ? true : false

          #
          Erp::Products::Product.get_all_len_codes.each_with_index do |code, line_num|
            @line_totals[line_num] = '--'
            
            row = {}
            row[:code] = code

            filters = params.to_unsafe_hash[:global_filter][:filters]
            filters.each_with_index do |m, index|
              @global_filter = m[1]
              
              if @global_filter[:categories].present?
                # period
                @from = @global_filter[:from_date].present? ? @global_filter[:from_date].to_date : nil
                @to = @global_filter[:to_date].present? ? @global_filter[:to_date].to_date : nil
                if @global_filter[:period].present?
                  @period = Erp::Periods::Period.find(@global_filter[:period])
                  @from = @period.from_date
                  @to = @period.to_date
                end
  
                # product query
                @product_query = Erp::Products::Product.get_active
                @product_query = @product_query.where(category_id: @global_filter[:categories]) if @global_filter[:categories].present?
  
                # get diameters
                diameter_ids = @global_filter[:diameters].present? ? @global_filter[:diameters] : nil
                @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)
                # filter by diameters
                if diameter_ids.present?
                  if !diameter_ids.kind_of?(Array)
                    @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{diameter_ids}\",%'")
                  else
                    diameter_ids = (diameter_ids.reject { |c| c.empty? })
                    if !diameter_ids.empty?
                      qs = []
                      diameter_ids.each do |x|
                        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
                      end
                      @product_query = @product_query.where("(#{qs.join(" OR ")})")
                    end
                  end
                end
  
                # get area name
                ns = []
                ns << @diameters.map(&:value).join(',') if @diameters.present?
                ns << Erp::Products::Category.where(id: @global_filter[:categories]).map(&:name).join('|') if @global_filter[:categories].present?
                ns << Erp::Warehouses::Warehouse.where(id: @global_filter[:warehouses]).map(&:name).join('|') if @global_filter[:warehouses].present?
                area_name = ns.join('-')
  
                # totals
                if !@totals[area_name].present?
                  #product_ids = @product_query.find_by_properties_value_ids([chu_pv.id,so_pv.id]).select('id')
                  product_ids = @product_query.select('id')
  
                  if @product_query.count > 0
                    product_ids = -1 if product_ids.count == 0
  
                    filters = @global_filter.clone.merge({
                      product_id: product_ids,
                      state_ids: @global_filter[:states],
                      warehouse_ids: @global_filter[:warehouses]
                    })
                    if show_virtual
                      stock = Erp::Products::Product.get_stock_virtual(filters)
                    else
                      stock = Erp::Products::Product.get_stock_real(filters)
                    end
                  else
                    stock = "--"
                  end
  
                  @totals[area_name] = stock
                  
                  # all total
                  @all_total += stock
                end
  
                # find by code
                @product_query = @product_query.where("name LIKE ?", "#{code}-%")
  
                #product_ids = @product_query.find_by_properties_value_ids([chu_pv.id,so_pv.id]).select('id')
                product_ids = @product_query.select('id')
  
                if @product_query.count > 0
                  product_ids = -1 if product_ids.count == 0
  
                  filters = @global_filter.clone.merge({
                    product_id: product_ids,
                    state_ids: @global_filter[:states],
                    warehouse_ids: @global_filter[:warehouses]
                  })
                  if show_virtual
                    stock = Erp::Products::Product.get_stock_virtual(filters)
                  else
                    stock = Erp::Products::Product.get_stock_real(filters)
                  end
                else
                  stock = "--"
                end
                
                # line total
                if stock != '--'
                  if @line_totals[line_num] == '--'
                    @line_totals[line_num] = stock
                  else
                    @line_totals[line_num] += stock
                  end
                end
  
                # add row
                row[area_name] = stock
  
                # heads name
                @heads << area_name if !@heads.include?(area_name)
              end
            end


            @rows << row if row != false
          end

          File.open("tmp/purchasing_export.yml", "w+") do |f|
            f.write({rows: @rows, heads: @heads, totals: @totals, line_totals: @line_totals, all_total: @all_total}.to_yaml)
          end

          render layout: nil
        end

        def purchasing_export_xlsx
          data = YAML.load_file("tmp/purchasing_export.yml")

          @rows = data[:rows]
          @heads = data[:heads]
          @totals = data[:totals]
          @line_totals = data[:line_totals]
          @all_total = data[:all_total]

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=Xuat_ton_kho_tuy_chon.xlsx"
            }
          end
        end
      end
    end
  end
end
