module Erp
  module OrthoK
    module Backend
      class ProductsController < Erp::Backend::BackendController
        # Matrix report
        def matrix_report
        end

        def matrix_report_table
          global_filter = params.to_unsafe_hash[:global_filter]
          if global_filter.present? and global_filter[:column].present?
            col = global_filter[:column].split('-').first
            @columns = Erp::Products::PropertiesValue.where(
              property_id: col
            )

            # sub columns
            if global_filter[:column].split('-').count == 2
              sub = global_filter[:column].split('-').last
              @column_subs = Erp::Products::PropertiesValue.where(
                property_id: sub
              )
            end
          end

          if global_filter.present? and global_filter[:row].present?
            row = global_filter[:row].split('-').first
            @rows = Erp::Products::PropertiesValue.where(
              property_id: global_filter[:row]
            )

            # sub rows
            if global_filter[:row].split('-').count == 2
              sub = global_filter[:row].split('-').last
              @row_subs = Erp::Products::PropertiesValue.where(
                property_id: sub
              )
            end
          end

          @global_filter = global_filter
          render layout: nil
        end

        def tooltip_warehouse_info

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

          @products_query = Erp::Products::Product.search(params).delivery_report(filters: @global_filters)

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
              .joins(:category)
              .order("ordered_code")

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
          @product_query = Erp::Products::Product.joins(:cache_stocks)
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


          if @to_warehouse.present? and @from_warehouse.present? and @state.present?
            if @condition == 'to_required'
              @product_query = @product_query.where(erp_products_cache_stocks: {warehouse_id: @to_warehouse.id, state_id: @state.id})
                .where("stock <= ?", @condition_value)
            elsif @condition == 'from_redundant'
              @product_query = @product_query.where(erp_products_cache_stocks: {warehouse_id: @from_warehouse.id, state_id: @state.id})
                .where("stock >= ?", @condition_value)
            end
          end

          @products = @product_query.limit(100)

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

          if @from_date.present? and @to_date.present?
            @rows = Erp::Products::Product.import_export_report(@global_filters)[:data].sort_by { |n| n[:voucher_date] }.reverse!
            @totals = Erp::Products::Product.import_export_report(@global_filters)[:total]
          end

          render layout: nil
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
                name: row["Tên hàng"].to_s.strip.downcase,
                category: row["Loại"].to_s.strip.downcase,
                diameter: row["Đường kính"].to_s.strip.downcase,
                letter: row["Chữ"].to_s.strip.downcase,
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
                .where("LOWER(value) = ?", data[:letter]).first
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

                # logger.info product.errors.to_json

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
      end
    end
  end
end
