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
            @columns = Erp::Products::PropertiesValue.where(
              property_id: global_filter[:column]
            )

            # sub columns
            if global_filter[:column_sub].present?
              @column_subs = Erp::Products::PropertiesValue.where(
                property_id: global_filter[:column_sub]
              )
            end
          end

          if global_filter.present? and global_filter[:row].present?
            @rows = Erp::Products::PropertiesValue.where(
                property_id: global_filter[:row]
              )

            # sub rows
            if global_filter[:row_sub].present?
              @row_subs = Erp::Products::PropertiesValue.where(
                property_id: global_filter[:row_sub]
              )
            end
          end

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

          ids = Erp::Products::Product.pluck(:id).sample(rand(90..250))
          @products = Erp::Products::Product.where(id: ids).order(:code)
          @center_quantity = (global_filters.present? and global_filters[:center_quantity].present? ? global_filters[:center_quantity].to_i : 0)
          @import_quantity = (global_filters.present? and global_filters[:import_quantity].present? ? global_filters[:import_quantity].to_i : 0)

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
      end
    end
  end
end
