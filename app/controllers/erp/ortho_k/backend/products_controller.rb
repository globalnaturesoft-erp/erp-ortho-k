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

          @products_query = Erp::Products::Product.delivery_report(filters: @global_filters)

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

          @products = @products_query.order("code").paginate(:page => params[:page], :per_page => 50)
          @warehouses = Erp::Warehouses::Warehouse.all.order("name")

          render layout: nil
        end

        # Stock importing
        def stock_importing
        end

        def stock_importing_table
          global_filters = params.to_unsafe_hash[:global_filter]

          @products = Erp::Products::Product.get_stock_importing_product(filters: global_filters)
            .joins(:category)
            .order("erp_products_categories.name, cache_diameter, code")

          @side_quantity = (global_filters.present? and global_filters[:side_quantity].present? ? global_filters[:side_quantity].to_i : 0)
          @central_quantity = (global_filters.present? and global_filters[:central_quantity].present? ? global_filters[:central_quantity].to_i : 0)
          @area = (global_filters.present? and global_filters[:area].present? ? global_filters[:area] : nil)

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
          @rows = Erp::Products::Product.import_export_report(params)[:data]
          @totals = Erp::Products::Product.import_export_report(params)[:total]

          render layout: nil
        end

        # Export report
        def export_report
        end

        def export_report_table
          @rows = Erp::Products::Product.export_report(params)

          render layout: nil
        end
      end
    end
  end
end
