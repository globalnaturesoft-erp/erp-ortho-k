module Erp
  module OrthoK
    module Backend
      class InventoryController < Erp::Backend::BackendController
        def report_category_diameter
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_category_diameter_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.where(category_id: category_ids)
          # filter by diameters
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

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end
        end

        def report_category_diameter_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.where(category_id: category_ids)
          # filter by diameters
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

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke ton kho.xlsx"'
            }
          end
        end


        def report_product
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_product_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # get diameters
          letter_ids = @global_filters[:letters].present? ? @global_filters[:letters] : nil
          @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

          # get numbers
          number_ids = @global_filters[:numbers].present? ? @global_filters[:numbers] : nil
          @numbers = Erp::Products::PropertiesValue.where(id: number_ids)


          # product query
          @product_query = Erp::Products::Product.joins(:category).where(category_id: category_ids).order('erp_products_categories.name, erp_products_products.name')
          # single keyword
          if params.to_unsafe_hash[:keyword].present?
            keyword = params.to_unsafe_hash[:keyword].strip.downcase
            keyword.split(' ').each do |q|
              q = q.strip
              @product_query = @product_query.where('LOWER(erp_products_products.cache_search) LIKE ?', '%'+q+'%')
            end
          end
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

          # products
          @products = @product_query.order('erp_products_categories.name, erp_products_products.name').paginate(:page => params[:page], :per_page => 20)

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end
        end

        def report_product_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # get diameters
          letter_ids = @global_filters[:letters].present? ? @global_filters[:letters] : nil
          @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

          # get numbers
          number_ids = @global_filters[:numbers].present? ? @global_filters[:numbers] : nil
          @numbers = Erp::Products::PropertiesValue.where(id: number_ids)


          # product query
          @product_query = Erp::Products::Product.where(category_id: category_ids)
          # single keyword
          if params.to_unsafe_hash[:keyword].present?
            keyword = params.to_unsafe_hash[:keyword].strip.downcase
            keyword.split(' ').each do |q|
              q = q.strip
              @product_query = @product_query.where('LOWER(erp_products_products.cache_search) LIKE ?', '%'+q+'%')
            end
          end
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

          # products
          @products = @product_query

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke ton kho theo san pham.xlsx"'
            }
          end
        end

        def report_central_area
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_central_area_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.where(category_id: category_ids)
          # filter by diameters
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

          # central area
          @central_query = @product_query.get_in_central_area
          @not_central_query = @product_query.get_not_in_central_area

          # warehouses
          @warehouses = Erp::Warehouses::Warehouse.where(id: @global_filters["warehouse_ids"])
        end

        def report_central_area_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.where(category_id: category_ids)
          # filter by diameters
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

          # central area
          @central_query = @product_query.get_in_central_area
          @not_central_query = @product_query.get_not_in_central_area

          # warehouses
          @warehouses = Erp::Warehouses::Warehouse.where(id: @global_filters["warehouse_ids"])

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke vung trung tam.xlsx"'
            }
          end
        end



        def report_warehouse
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_warehouse_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : []
          @categories = (category_ids.empty? ? Erp::Products::Category.all : Erp::Products::Category.where(id: category_ids))

          # product query
          @product_query = Erp::Products::Product.all
          @product_query = @product_query.where(category_id: category_ids) if category_ids.present?

          # warehouses
          @warehouses = Erp::Warehouses::Warehouse.where(id: @global_filters["warehouse_ids"])
        end

        def report_warehouse_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : []
          @categories = (category_ids.empty? ? Erp::Products::Category.all : Erp::Products::Category.where(id: category_ids))

          # product query
          @product_query = Erp::Products::Product.all
          @product_query = @product_query.where(category_id: category_ids) if category_ids.present?

          # warehouses
          @warehouses = Erp::Warehouses::Warehouse.where(id: @global_filters["warehouse_ids"])

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke kho.xlsx"'
            }
          end
        end




        def report_custom_area
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_custom_area_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # get diameters
          @letter_array = []
          (0..100).each do |num|
            if @global_filters['letters_'+num.to_s].present?
              letter_ids = @global_filters['letters_'+num.to_s]
              @letters = Erp::Products::PropertiesValue.where(id: letter_ids).order('value')

              @letter_array << {letter_ids: letter_ids, letters: @letters}
            end
          end

          @product_query = Erp::Products::Product
          # product query
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
        end

        def report_custom_area_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # get diameters
          @letter_array = []
          (0..100).each do |num|
            if @global_filters['letters_'+num.to_s].present?
              letter_ids = @global_filters['letters_'+num.to_s]
              @letters = Erp::Products::PropertiesValue.where(id: letter_ids).order('value')

              @letter_array << {letter_ids: letter_ids, letters: @letters}
            end
          end

          @product_query = Erp::Products::Product
          # product query
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

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke theo vung.xlsx"'
            }
          end
        end



        def report_outside_product
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_outside_product_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # product query
          @product_query = Erp::Products::Product.where(is_outside: true)
          @product_query = @product_query.where(category_id: category_ids) if category_ids.present?

          # products
          @products = @product_query.paginate(:page => params[:page], :per_page => 50)
        end

        def report_outside_product_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # product query
          @product_query = Erp::Products::Product.where(is_outside: true)
          @product_query = @product_query.where(category_id: category_ids) if category_ids.present?

          # products
          @products = @product_query

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke len ngoai bang.xlsx"'
            }
          end
        end



        def report_product_warehouse
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_product_warehouse_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # get diameters
          letter_ids = @global_filters[:letters].present? ? @global_filters[:letters] : nil
          @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

          # get numbers
          number_ids = @global_filters[:numbers].present? ? @global_filters[:numbers] : nil
          @numbers = Erp::Products::PropertiesValue.where(id: number_ids)

          # warehouses
          @warehouses = Erp::Warehouses::Warehouse.all

          # product query
          @product_query = Erp::Products::Product.where(category_id: category_ids)
          # single keyword
          if params.to_unsafe_hash[:keyword].present?
            keyword = params.to_unsafe_hash[:keyword].strip.downcase
            keyword.split(' ').each do |q|
              q = q.strip
              @product_query = @product_query.where('LOWER(erp_products_products.cache_search) LIKE ?', '%'+q+'%')
            end
          end
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

          # products
          @products = @product_query.paginate(:page => params[:page], :per_page => 20)
        end

        def report_product_warehouse_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # get diameters
          letter_ids = @global_filters[:letters].present? ? @global_filters[:letters] : nil
          @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

          # get numbers
          number_ids = @global_filters[:numbers].present? ? @global_filters[:numbers] : nil
          @numbers = Erp::Products::PropertiesValue.where(id: number_ids)

          # warehouses
          @warehouses = Erp::Warehouses::Warehouse.all

          # product query
          @product_query = Erp::Products::Product.where(category_id: category_ids)
          # single keyword
          if params.to_unsafe_hash[:keyword].present?
            keyword = params.to_unsafe_hash[:keyword].strip.downcase
            keyword.split(' ').each do |q|
              q = q.strip
              @product_query = @product_query.where('LOWER(erp_products_products.cache_search) LIKE ?', '%'+q+'%')
            end
          end
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

          # products
          @products = @product_query

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke hang ton theo kho va san pham.xlsx"'
            }
          end
        end




        def report_custom_area_v2
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_custom_area_v2_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # area array
          @rows = []
          # categories each
          if @global_filters[:categories].present? and @global_filters[:letters].present? and @global_filters[:numbers_diameters].present?
            @global_filters[:categories] = @global_filters[:categories].kind_of?(Array) ? @global_filters[:categories] : [@global_filters[:categories]]
            @global_filters[:categories].each do |category_id|
              span = (@global_filters[:letters].count)
              row = {category: Erp::Products::Category.find(category_id), letter_groups: [], span: 0}

              # letters each
              @global_filters[:letters].each do |lrow|
                row_2 = {letter_ids: lrow[1], numbers_diameters: []}

                # numbers diameters
                @global_filters[:numbers_diameters].each do |ndrow|
                  row_2[:numbers_diameters] << {number_ids: ndrow[1][:numbers], diameter_ids: ndrow[1][:diameters]}
                end

                # letters
                row[:letter_groups] << row_2
              end

              @rows << row
            end
          end

          @product_query = Erp::Products::Product

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end
        end

        def report_custom_area_v2_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          # area array
          @rows = []
          # categories each
          if @global_filters[:categories].present? and @global_filters[:letters].present? and @global_filters[:numbers_diameters].present?
            @global_filters[:categories] = @global_filters[:categories].kind_of?(Array) ? @global_filters[:categories] : [@global_filters[:categories]]
            @global_filters[:categories].each do |category_id|
              span = (@global_filters[:letters].count)
              row = {category: Erp::Products::Category.find(category_id), letter_groups: [], span: 0}

              # letters each
              @global_filters[:letters].each do |lrow|
                row_2 = {letter_ids: lrow[1], numbers_diameters: []}

                # numbers diameters
                @global_filters[:numbers_diameters].each do |ndrow|
                  row_2[:numbers_diameters] << {number_ids: ndrow[1][:numbers], diameter_ids: ndrow[1][:diameters]}
                end

                # letters
                row[:letter_groups] << row_2
              end

              @rows << row
            end
          end

          @product_query = Erp::Products::Product

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke ton kho theo vung (tuy chon).xlsx"'
            }
          end
        end

        def report_product_request
        end

        def report_product_request_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          @product_query = Erp::Products::Product

          # catgories
          @product_query = @product_query.where(category_id: @global_filters[:categories]) if @global_filters[:categories].present?

          # diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
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
        end
        
        def report_product_request_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          @product_query = Erp::Products::Product

          # catgories
          @product_query = @product_query.where(category_id: @global_filters[:categories]) if @global_filters[:categories].present?

          # diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
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
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename='Ma tran nhu cau mua hang.xlsx'"
            }
          end
        end

        def report_product_ordered
        end

        def report_product_ordered_table
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          @product_query = Erp::Products::Product

          # catgories
          @product_query = @product_query.where(category_id: @global_filters[:categories]) if @global_filters[:categories].present?

          # diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
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
        end
        
        def report_product_ordered_xlsx
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          @product_query = Erp::Products::Product

          # catgories
          @product_query = @product_query.where(category_id: @global_filters[:categories]) if @global_filters[:categories].present?

          # diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
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
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename='Ma tran so luong ban hang.xlsx'"
            }
          end
        end
      end
    end
  end
end
