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

          # product query
          @product_query = Erp::Products::Product.where(category_id: category_ids)

          # products
          @products = @product_query.paginate(:page => params[:page], :per_page => 25)
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

          # warehouses
          @warehouses = Erp::Warehouses::Warehouse.where(id: @global_filters["warehouse_ids"])
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
          ## filter by letters
          #if letter_ids.present?
          #  if !letter_ids.kind_of?(Array)
          #    @product_query = @product_query.where("erp_products_products.cache_properties LIKE '%[\"#{letter_ids}\",%'")
          #  else
          #    letter_ids = (letter_ids.reject { |c| c.empty? })
          #    if !letter_ids.empty?
          #      qs = []
          #      letter_ids.each do |x|
          #        qs << "(erp_products_products.cache_properties LIKE '%[\"#{x}\",%')"
          #      end
          #      @product_query = @product_query.where("(#{qs.join(" OR ")})")
          #    end
          #  end
          #end
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
      end
    end
  end
end
