module Erp
  module OrthoK
    module Backend
      class InventoryController < Erp::Backend::BackendController
        def report_category_diameter
          authorize! :report_inventory_category_diameter, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_category_diameter_table
          authorize! :report_inventory_category_diameter, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          
          ## neu chon len cung/ hien thi danh sach cac chuyen muc con cua len cung
          len_cung = Erp::Products::Category.where(name: 'Len cứng').first
          
          if !category_ids.kind_of?(Array) and category_ids == len_cung.id.to_s # dieu kien khi chon 1 len cung
            category_ids = len_cung.children.where(archived: false).ids.map(&:to_s)
          elsif category_ids.kind_of?(Array) and category_ids.include?("#{len_cung.id}") # dieu kien khi chon nhieu len/gom len cung
            category_ids += len_cung.children.where(archived: false).ids.map(&:to_s)
            category_ids.delete(len_cung.id.to_s)
            category_ids = category_ids.uniq
          end
          
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.get_active.where(category_id: category_ids)

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
          
          File.open("tmp/report_category_diameter_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters
            }.to_yaml)
          end
        end

        def report_category_diameter_xlsx
          authorize! :report_inventory_category_diameter, nil
          
          data = YAML.load_file("tmp/report_category_diameter_#{current_user.id}.yml")
          
          @global_filters = data[:global_filters]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.get_active.where(category_id: category_ids)

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
          authorize! :report_inventory_product, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_product_table
          authorize! :report_inventory_product, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          @is_set_type_selected = @global_filters[:categories] == Erp::Products::Category.get_set.id.to_s

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

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
          @product_query = Erp::Products::Product.get_active.joins(:category).where(category_id: category_ids)
            .order('erp_products_products.ordered_code, erp_products_products.name')
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

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end
          
          File.open("tmp/report_product_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              params: params,
            }.to_yaml)
          end
        end

        def report_product_xlsx
          authorize! :report_inventory_product, nil
          
          data = YAML.load_file("tmp/report_product_#{current_user.id}.yml")
          params = data[:params]
          @global_filters = data[:global_filters]

          @is_set_type_selected = @global_filters[:categories] == Erp::Products::Category.get_set.id.to_s

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

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
          @product_query = Erp::Products::Product.get_active.where(category_id: category_ids)
            .order('erp_products_products.ordered_code, erp_products_products.name')
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
          authorize! :report_inventory_central_area, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_central_area_table
          authorize! :report_inventory_central_area, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.get_active.where(category_id: category_ids)
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
          
          File.open("tmp/report_central_area_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
            }.to_yaml)
          end
        end

        def report_central_area_xlsx
          authorize! :report_inventory_central_area, nil
          
          data = YAML.load_file("tmp/report_central_area_#{current_user.id}.yml")

          @global_filters = data[:global_filters]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.get_active.where(category_id: category_ids)
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
          authorize! :report_inventory_warehouse, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_warehouse_table
          authorize! :report_inventory_warehouse, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          @to_date = @global_filters[:to_date].to_date          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : []
          @categories = (category_ids.empty? ? Erp::Products::Category.all : Erp::Products::Category.where(id: category_ids))

          # product query
          @product_query = Erp::Products::Product.get_active
          @product_query = @product_query.where(category_id: category_ids) if category_ids.present?

          # warehouses
          @warehouses = Erp::Warehouses::Warehouse.where(id: @global_filters["warehouse_ids"])
          
          File.open("tmp/report_warehouse_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
            }.to_yaml)
          end
        end

        def report_warehouse_xlsx
          authorize! :report_inventory_warehouse, nil
          
          data = YAML.load_file("tmp/report_warehouse_#{current_user.id}.yml")

          @global_filters = data[:global_filters]
          
          
          @to_date = @global_filters[:to_date].to_date          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : []
          @categories = (category_ids.empty? ? Erp::Products::Category.all : Erp::Products::Category.where(id: category_ids))

          # product query
          @product_query = Erp::Products::Product.get_active
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
          authorize! :report_inventory_custom_area, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_custom_area_table
          authorize! :report_inventory_custom_area, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

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

          @product_query = Erp::Products::Product.get_active
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
          
          File.open("tmp/report_custom_area_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
            }.to_yaml)
          end
        end

        def report_custom_area_xlsx
          authorize! :report_inventory_custom_area, nil
          
          data = YAML.load_file("tmp/report_custom_area_#{current_user.id}.yml")

          @global_filters = data[:global_filters]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

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

          @product_query = Erp::Products::Product.get_active
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
          authorize! :report_inventory_outside_product, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_outside_product_table
          authorize! :report_inventory_outside_product, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get categories
          category_ids = @global_filters[:categories].present? ? @global_filters[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # product query
          @product_query = Erp::Products::Product.get_active.where(is_outside: true)
          @product_query = @product_query.where(category_id: category_ids) if category_ids.present?
          
          # min stock
          if @global_filters[:min_stock].present?
            min_stock = @global_filters[:min_stock].to_i
            if min_stock > 0
              pids = []
              @product_query.each do |p|
                if p.get_stock(to_date: @to_date) >= min_stock
                  pids << p.id
                end
              end
              
              @product_query = @product_query.where(id: pids)
            end
          end

          # products
          @products = @product_query.order('ordered_code') #.paginate(:page => params[:page], :per_page => 50)
          
          # total
          @total = {}
          product_ids = @product_query.select('id')
          product_ids = -1 if product_ids.count == 0
          filters = @global_filters.clone.merge({product_id: product_ids})
          
          begin_params = filters.clone
          begin_params[:to_date] = filters[:from_date]
          begin_params[:from_date] = nil
          @total[:begin] = Erp::Products::Product.get_stock_real(begin_params)
          
          @total[:col1] = Erp::Products::Product.get_qdelivery_import(filters.clone.merge({
              delivery_type: [
                Erp::Qdeliveries::Delivery::TYPE_CUSTOM_IMPORT,
                Erp::Qdeliveries::Delivery::TYPE_PURCHASE_IMPORT
              ]
          }))
          
          @total[:col2] = Erp::Products::Product.get_qdelivery_import(filters.clone.merge({
              delivery_type: [                  
                Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT
              ]
          })) + Erp::Products::Product.get_cs_return_import(filters)
          
          @total[:col3] = Erp::Products::Product.get_qdelivery_export(filters.clone.merge({
              delivery_type: [
                Erp::Qdeliveries::Delivery::TYPE_CUSTOM_EXPORT,
                Erp::Qdeliveries::Delivery::TYPE_SALES_EXPORT
              ]
          })) + Erp::Products::Product.get_gift_given_export(filters) + Erp::Products::Product.get_consignment_export(filters)
          
          @total[:col4] = Erp::Products::Product.get_damage_record_export(filters) + Erp::Products::Product.get_stock_check_export(filters)
          
          @total[:col5] = Erp::Products::Product.get_qdelivery_export(filters.clone.merge({
              delivery_type: [                  
                Erp::Qdeliveries::Delivery::TYPE_PURCHASE_EXPORT
              ]
          }))
          
          end_params = filters.clone
          end_params[:from_date] = nil        
          @total[:end] = e_stock = Erp::Products::Product.get_stock_real(end_params)
          
          
          # rows
          @rows = []
          @products.each do |product|
            filters = @global_filters.clone.merge(product_id: product.id)
            
            row = {}
            row[:product] = product
            
            begin_params = filters.clone
            begin_params[:to_date] = filters[:from_date]
            begin_params[:from_date] = nil
            row[:begin] = Erp::Products::Product.get_stock_real(begin_params)
            
            row[:col1] = Erp::Products::Product.get_qdelivery_import(filters.clone.merge({
                delivery_type: [
                  Erp::Qdeliveries::Delivery::TYPE_CUSTOM_IMPORT,
                  Erp::Qdeliveries::Delivery::TYPE_PURCHASE_IMPORT
                ]
            }))
            
            row[:col2] = Erp::Products::Product.get_qdelivery_import(filters.clone.merge({
                delivery_type: [                  
                  Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT
                ]
            }))
            
            row[:col3] = Erp::Products::Product.get_qdelivery_export(filters.clone.merge({
                delivery_type: [
                  Erp::Qdeliveries::Delivery::TYPE_CUSTOM_EXPORT,
                  Erp::Qdeliveries::Delivery::TYPE_SALES_EXPORT
                ]
            })) + Erp::Products::Product.get_gift_given_export(filters) + Erp::Products::Product.get_consignment_export(filters)
            
            row[:col4] = Erp::Products::Product.get_damage_record_export(filters) + Erp::Products::Product.get_stock_check_export(filters)
            
            row[:col5] = Erp::Products::Product.get_qdelivery_export(filters.clone.merge({
                delivery_type: [                  
                  Erp::Qdeliveries::Delivery::TYPE_PURCHASE_EXPORT
                ]
            }))
            
            end_params = filters.clone
            end_params[:from_date] = nil
          
            row[:end] = e_stock = Erp::Products::Product.get_stock_real(end_params)
            
            if row[:end] >= @global_filters[:min_stock].to_i
              @rows << row
            end
          end
          
          File.open("tmp/report_outside_product_#{current_user.id}.yml", "w+") do |f|
            f.write({
              period: @period,
              from_date: @from_date,
              to_date: @to_date,
              rows: @rows,
              total: @total
            }.to_yaml)
          end
        end

        def report_outside_product_xlsx
          authorize! :report_inventory_outside_product, nil
          
          data = YAML.load_file("tmp/report_outside_product_#{current_user.id}.yml")
          
          @period = data[:period]
          @from_date = data[:from_date]
          @to_date = data[:to_date]
          @rows = data[:rows]
          @total = data[:total]

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke len ngoai bang.xlsx"'
            }
          end
        end



        def report_product_warehouse
          authorize! :report_inventory_product_warehouse, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_product_warehouse_table
          authorize! :report_inventory_product_warehouse, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          @to_date = @global_filters[:to_date].to_date
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

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
          @warehouses = Erp::Warehouses::Warehouse.all_active

          # product query
          @product_query = Erp::Products::Product.get_active.where(category_id: category_ids)
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
          @products = @product_query.order('ordered_code, name').paginate(:page => params[:page], :per_page => 20)
          
          File.open("tmp/report_product_warehouse_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              params: params,
            }.to_yaml)
          end
        end

        def report_product_warehouse_xlsx
          authorize! :report_inventory_product_warehouse, nil
          
          data = YAML.load_file("tmp/report_product_warehouse_#{current_user.id}.yml")
          params = data[:params]
          @global_filters = data[:global_filters]
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

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
          @warehouses = Erp::Warehouses::Warehouse.all_active

          # product query
          @product_query = Erp::Products::Product.get_active.where(category_id: category_ids)
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
          @products = @product_query.order('ordered_code, name')

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke hang ton theo kho va san pham.xlsx"'
            }
          end
        end




        def report_custom_area_v2
          authorize! :report_inventory_custom_area_v2, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_custom_area_v2_table
          authorize! :report_inventory_custom_area_v2, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end
          
          @multi_rows = []
          
          @global_filters[:areas].each do |arow|
              filters = arow[1]
            
              # area array
              rows = []
              # categories each
              if filters[:categories].present? and filters[:letters].present? and filters[:numbers_diameters].present?
                filters[:categories] = filters[:categories].kind_of?(Array) ? filters[:categories] : [filters[:categories]]
                filters[:categories].each do |category_id|
                  span = (filters[:letters].count)
                  row = {category: Erp::Products::Category.find(category_id), letter_groups: [], span: 0}
    
                  # letters each
                  filters[:letters].each do |lrow|
                    row_2 = {letter_ids: lrow[1], numbers_diameters: []}
    
                    # numbers diameters
                    filters[:numbers_diameters].each do |ndrow|
                      row_2[:numbers_diameters] << {number_ids: ndrow[1][:numbers], diameter_ids: ndrow[1][:diameters]}
                    end
    
                    # letters
                    row[:letter_groups] << row_2
                  end
    
                  rows << row
                end
              end
              
            @multi_rows << rows if !rows.empty?
          end

          @product_query = Erp::Products::Product.get_active

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end
          
          File.open("tmp/report_custom_area_v2_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period: @period,
              from_date: @from_date,
              to_date: @to_date,
              multi_rows: @multi_rows,
              #product_query: @product_query,
              states: @states
            }.to_yaml)
          end
        end

        def report_custom_area_v2_xlsx
          authorize! :report_inventory_custom_area_v2, nil
          
          data = YAML.load_file("tmp/report_custom_area_v2_#{current_user.id}.yml")
          
          @global_filters = data[:global_filters]
          @period = data[:period]
          @from_date = data[:from_date]
          @to_date = data[:to_date]
          @multi_rows = data[:multi_rows]
          #@product_query = data[:product_query]
          @states = data[:states]
          
          @product_query = Erp::Products::Product.get_active
          

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke ton kho theo vung (tuy chon).xlsx"'
            }
          end
        end

        # get product request matrixes
        def get_product_request_matrixes(filter)
          @global_filter = filter

          if @global_filter[:period].present?
            @period = Erp::Periods::Period.find(@global_filter[:period])
            @global_filter[:from_date] = @period.from_date
            @global_filter[:to_date] = @period.to_date
          end

          @from_date = @global_filter[:from_date].to_date
          @to_date = @global_filter[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filter[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filter[:to_date] = @to_date
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
              @matrix[0] << {value: col[:degree]}
          end

          # row 2
          @matrix[1] = []
          @matrix[1][0] = {value: ''}
          @matrix[1][1] = {value: ''}
          Erp::Products::Product.matrix_cols.each do |col|
              @matrix[1] << {value: col[:letter]}
          end

          so_p = Erp::Products::Property.get_number
          chu_p = Erp::Products::Property.get_letter

          # rows and cols
          Erp::Products::Product.matrix_rows.each_with_index do |row, index|
            row_index = index + 2
            @matrix[row_index] = []

            @matrix[row_index][0] = {value: row[:degree_k]}
            @matrix[row_index][1] = {value: row[:number]}

            Erp::Products::Product.matrix_cols.each do |col|
              chu_pv = Erp::Products::PropertiesValue.where(property_id: chu_p.id, value: col[:letter]).first
              so_pv = Erp::Products::PropertiesValue.where(property_id: so_p.id, value: row[:number]).first

              # @product_query.count
              query = @product_query
              query = query.find_by_properties_value_ids([chu_pv.id,so_pv.id])
              product_ids = query.select('erp_products_products.id')
              product_ids = -1 if query.count == 0
              # stock
              stock = Erp::Products::Product.get_order_request_count(
                  product_id: product_ids,
                  warehouse_ids: @global_filter[:warehouses],
                  state_ids: @global_filter[:states],
                  from_date: @from_date,
                  to_date: @to_date,
              )

              @matrix[row_index] << {
                value: stock
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

          return {filter: @global_filter, matrix: @matrix, summary: @summary, period: @period, from_date: @from_date, to_date: @to_date}
        end

        def report_product_request
          authorize! :report_inventory_product_request, nil
        end

        def report_product_request_table
          authorize! :report_inventory_product_request, nil
          
          filters = params.to_unsafe_hash[:global_filter]

          @matrixes = []

          # filters.each do |m|
            @matrixes << self.get_product_request_matrixes(filters)
          # end

          File.open("tmp/report_product_request_#{current_user.id}.yml", "w+") do |f|
            f.write(@matrixes.to_yaml)
          end

          render layout: nil
        end

        def report_product_request_xlsx
          authorize! :report_inventory_product_request, nil
          
          @matrixes = YAML.load_file("tmp/report_product_request_#{current_user.id}.yml")

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=Ma_tran_nhu_cau_mua.xlsx"
            }
          end
        end

        # get product request matrixes
        def get_product_ordered_matrixes(filter)
          @global_filter = filter

          if @global_filter[:period].present?
            @period = Erp::Periods::Period.find(@global_filter[:period])
            @global_filter[:from_date] = @period.from_date
            @global_filter[:to_date] = @period.to_date
          end

          @from_date = @global_filter[:from_date].to_date
          @to_date = @global_filter[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filter[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filter[:to_date] = @to_date
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
              @matrix[0] << {value: col[:degree]}
          end

          # row 2
          @matrix[1] = []
          @matrix[1][0] = {value: ''}
          @matrix[1][1] = {value: ''}
          Erp::Products::Product.matrix_cols.each do |col|
              @matrix[1] << {value: col[:letter]}
          end

          so_p = Erp::Products::Property.get_number
          chu_p = Erp::Products::Property.get_letter

          # rows and cols
          Erp::Products::Product.matrix_rows.each_with_index do |row, index|
            row_index = index + 2
            @matrix[row_index] = []

            @matrix[row_index][0] = {value: row[:degree_k]}
            @matrix[row_index][1] = {value: row[:number]}

            Erp::Products::Product.matrix_cols.each do |col|
              chu_pv = Erp::Products::PropertiesValue.where(property_id: chu_p.id, value: col[:letter]).first
              so_pv = Erp::Products::PropertiesValue.where(property_id: so_p.id, value: row[:number]).first

              # @product_query.count
              query = @product_query
              query = query.find_by_properties_value_ids([chu_pv.id,so_pv.id])
              product_ids = query.select('erp_products_products.id')
              product_ids = -1 if query.count == 0
              # stock
              stock = Erp::Products::Product.get_order_export(
                  product_id: product_ids,
                  warehouse_ids: @global_filter[:warehouses],
                  state_ids: @global_filter[:states],
                  from_date: @from_date,
                  to_date: @to_date,
              )

              @matrix[row_index] << {
                value: stock
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

          return {filter: @global_filter, matrix: @matrix, summary: @summary, period: @period, from_date: @from_date, to_date: @to_date}
        end

        def report_product_ordered
          authorize! :report_inventory_product_ordered, nil
        end

        def report_product_ordered_table
          authorize! :report_inventory_product_ordered, nil
          
          filters = params.to_unsafe_hash[:global_filter]

          @matrixes = []

          # filters.each do |m|
            @matrixes << self.get_product_ordered_matrixes(filters)
          # end

          File.open("tmp/report_product_ordered_#{current_user.id}.yml", "w+") do |f|
            f.write(@matrixes.to_yaml)
          end

          render layout: nil
        end

        def report_product_ordered_xlsx
          authorize! :report_inventory_product_ordered, nil
          
          @matrixes = YAML.load_file("tmp/report_product_ordered_#{current_user.id}.yml")

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=Ma_tran_ban_hang.xlsx"
            }
          end
        end
        
        # Report custom products
        def report_custom_product
          authorize! :report_inventory_custom_product, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_custom_product_table
          authorize! :report_inventory_custom_product, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          @is_set_type_selected = @global_filters[:categories] == Erp::Products::Category.get_set.id.to_s

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

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
          @product_query = Erp::Products::Product.get_active.joins(:category).where(category_id: category_ids)
            .order('erp_products_products.ordered_code')
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
          
          # min stock
          if @global_filters[:min_stock].present?
            min_stock = @global_filters[:min_stock].to_i
            if min_stock > 0
              pids = []
              @product_query.each do |p|
                if p.get_stock(to_date: @to_date) >= min_stock
                  pids << p.id
                end
              end
              
              @product_query = @product_query.where(id: pids)
            end
          end

          # products
          @products = @product_query.order('erp_products_products.category_id, erp_products_products.ordered_code').paginate(:page => params[:page], :per_page => 1000)
          
          @list = []
          @products.each do |p|
            @list << {
              product: p,
              date: (p.last_delivery_detail(@global_filters).present? ? p.last_delivery_detail(@global_filters).delivery.date : nil),
              note: (p.last_delivery_detail(@global_filters).present? ? p.last_delivery_detail(@global_filters).delivery.note : nil),
              delivery: (p.last_delivery_detail(@global_filters).present? ? p.last_delivery_detail(@global_filters).delivery : nil)
            }
          end
          
          @list = (@list.sort_by { |row| row[:date].to_i }).reverse!

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end
          
          File.open("tmp/report_custom_product_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              params: params,
            }.to_yaml)
          end
        end

        def report_custom_product_xlsx
          authorize! :report_inventory_custom_product, nil
          
          data = YAML.load_file("tmp/report_custom_product_#{current_user.id}.yml")
          params = data[:params]
          @global_filters = data[:global_filters]

          @is_set_type_selected = @global_filters[:categories] == Erp::Products::Category.get_set.id.to_s

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

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
          @product_query = Erp::Products::Product.get_active.joins(:category).where(category_id: category_ids)
            .order('erp_products_products.ordered_code')
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
          
          # min stock
          if @global_filters[:min_stock].present?
            min_stock = @global_filters[:min_stock].to_i
            if min_stock > 0
              pids = []
              @product_query.each do |p|
                if p.get_stock(to_date: @to_date) >= min_stock
                  pids << p.id
                end
              end
              
              @product_query = @product_query.where(id: pids)
            end
          end

          # products
          @products = @product_query.order('erp_products_products.category_id, erp_products_products.ordered_code')
          
          @list = []
          @products.each do |p|
            @list << {
              product: p,
              date: (p.last_delivery_detail(@global_filters).present? ? p.last_delivery_detail(@global_filters).delivery.date : nil),
              note: (p.last_delivery_detail(@global_filters).present? ? p.last_delivery_detail(@global_filters).delivery.note : nil)
            }
          end
          
          @list = (@list.sort_by { |row| row[:date].to_i }).reverse!

          # state
          @states = Erp::Products::State.all_active
          if @global_filters[:state_ids].present?
            @states = Erp::Products::State.where(id: @global_filters[:state_ids])
          end

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke ton kho theo san pham custom.xlsx"'
            }
          end
        end
        
        def report_code_diameter
          authorize! :report_inventory_code_diameter, nil
          
          # default from to date
          @from_date = Time.now.beginning_of_month
          @to_date = Time.now.end_of_day

          @period = Erp::Periods::Period.where(name: "Tháng #{Time.now.month}/#{Time.now.year}").first
        end

        def report_code_diameter_table
          authorize! :report_inventory_code_diameter, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get letters
          letter_ids = @global_filters[:letters].present? ? @global_filters[:letters] : nil
          @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.get_active
          
          # filter by letters
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
          
          File.open("tmp/report_code_diameter_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
            }.to_yaml)
          end
        end

        def report_code_diameter_xlsx
          authorize! :report_inventory_code_diameter, nil
          
          data = YAML.load_file("tmp/report_code_diameter_#{current_user.id}.yml")
          
          @global_filters = data[:global_filters]

          # if has period
          if @global_filters[:period].present?
            @period = Erp::Periods::Period.find(@global_filters[:period])
            @global_filters[:from_date] = @period.from_date
            @global_filters[:to_date] = @period.to_date
          end

          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date
          
          if !@from_date.present?
            @from_date = Time.now.beginning_of_month
            @global_filters[:from_date] = @from_date
          end
          
          if !@to_date.present?
            @to_date = Time.now
            @global_filters[:to_date] = @to_date
          end

          # get letters
          letter_ids = @global_filters[:letters].present? ? @global_filters[:letters] : nil
          @letters = Erp::Products::PropertiesValue.where(id: letter_ids)

          # get diameters
          diameter_ids = @global_filters[:diameters].present? ? @global_filters[:diameters] : nil
          @diameters = Erp::Products::PropertiesValue.where(id: diameter_ids)

          # product query
          @product_query = Erp::Products::Product.get_active
          
          # filter by letters
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
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke ton kho Ma Duong kinh.xlsx"'
            }
          end
        end
      end
    end
  end
end
