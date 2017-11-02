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
        end

        def delivery_report_table
          # group bys
          global_filters = params.to_unsafe_hash[:global_filter]

          @group_by_category = (global_filters.present? and global_filters[:group_by_category].present?) ? global_filters[:group_by_category] : nil
          @group_by_property = (global_filters.present? and global_filters[:group_by_property].present?) ? global_filters[:group_by_property] : nil

          if @group_by_category.present?
            @categories = @group_by_category == 'all' ? Erp::Products::Category.order('name') : Erp::Products::Category.where(id: @group_by_category)
          end

          if @group_by_property.present?
            @properties_values = Erp::Products::PropertiesValue.where(property_id: @group_by_property).order('value')
          end

          @products = Erp::Products::Product.all.order("code").paginate(:page => params[:page], :per_page => 50)

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

          if @group_by_category.present?
            @categories = @group_by_category == 'all' ? Erp::Products::Category.order('name') : Erp::Products::Category.where(id: @group_by_category)
          end

          if @group_by_property.present?
            @properties_values = Erp::Products::PropertiesValue.where(property_id: @group_by_property).order('value')
          end

          @products = Erp::Products::Product.all.order("code").paginate(:page => params[:page], :per_page => 50)
          @warehouses = Erp::Warehouses::Warehouse.all.order("name")

          render layout: nil
        end

        # Stock importing
        def stock_importing
        end

        def stock_importing_table
          global_filters = params.to_unsafe_hash[:global_filter]

          @products = Erp::Products::Product.get_stock_importing_product(filters: global_filters).order(:code)

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
          @transfer_quantity = global_filters[:transfer_quantity]

          @condition = global_filters[:condition]
          @condition_value = global_filters[:condition_value]

          ids = Erp::Products::Product.pluck(:id).sample(rand(90..250))
          @products = Erp::Products::Product.where(id: ids).order(:code)

          render layout: nil
        end

        # Import report
        def import_report
        end

        def import_report_table
          @rows = Erp::Products::Product.import_report(params)

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
