module Erp
  module OrthoK
    module Backend
      class SalesController < Erp::Backend::BackendController
        # Bao cao ban va tra hang
        def report_sell_and_return_table
          glb = params.to_unsafe_hash[:global_filter]
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date : nil
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date : nil
          end

          if @from.present? and @to.present?
            @orders = Erp::Orders::Order.sales_orders.all_confirmed.search(params)
  
            @deliveries = Erp::Qdeliveries::Delivery.all_delivered.search(params)
                            .where(delivery_type: Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT)
            
            if glb[:group_by].include? '_state'
              @order_details = Erp::Orders::OrderDetail.includes(:order).where(order_id: @orders.select(:id)).order("erp_orders_orders.patient_state_id")
              @delivery_details = Erp::Qdeliveries::DeliveryDetail.where(delivery_id: @deliveries.select(:id))
              
              if glb[:group_by].include? 'patient_state'
                # order details rows
                @od_rows = @order_details.group_by { |d| d.order.patient_state }
                @dd_rows = @delivery_details.group_by { |d| (d.get_patient_state.present? ? d.get_patient_state.id : 10000) }
              elsif glb[:group_by].include? 'product_state'
                @od_rows = @order_details.group_by { |d| Erp::Products::State.get_new_state }
                @dd_rows = @delivery_details.group_by { |d| (d.state.present? ? d.state.id : 10000) }
              end
              
              @dd_rows = Hash[@dd_rows.sort_by{|k,v| k}]
            end
            
            @dd_rows = Hash[@dd_rows.sort_by{|k,v| k}]
          end
          
          File.open("tmp/report_sell_and_return_xlsx_#{current_user.id}.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              orders: @orders,
              deliveries: @deliveries,
              od_rows: @od_rows,
              dd_rows: @dd_rows,
            }.to_yaml)
          end
          
          if glb[:group_by].include? '_state'
            render "report_sell_and_return_state_table"
          else
            render "report_sell_and_return_order_table"
          end
        end

        def report_sell_and_return_xlsx
          data = YAML.load_file("tmp/report_sell_and_return_xlsx_#{current_user.id}.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date]
          @to = data[:to_date]
          @orders = data[:orders]
          @deliveries = data[:deliveries]
          @od_rows = data[:od_rows]
          @dd_rows = data[:dd_rows]
          
          @orders = Erp::Orders::Order.where(id: (@orders.map{|i| i.id}))
          @deliveries = Erp::Qdeliveries::Delivery.where(id: (@deliveries.map{|i| i.id}))

          respond_to do |format|
            format.xlsx {
              if @global_filters[:group_by].include? '_state'
                t = "report_sell_and_return_state_xlsx"
              else
                t = "report_sell_and_return_order_xlsx"
              end
              render xlsx: t, filename: "Bao cao ban va tra hang.xlsx"
            }
          end
        end

        # So chi tiet ban hang
        def report_sales_details_table
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
            if @group_by.present? and !@group_by.include?(Erp::Orders::Order::GROUPED_BY_DEFAULT)
              @groups = Erp::Orders::Order.group_sales_details_report(@global_filters)[:groups]
              @totals = Erp::Orders::Order.group_sales_details_report(@global_filters)[:totals]
            else              
              @rows = Erp::Orders::Order.sales_details_report(@global_filters)[:data].sort_by { |n| n[:voucher_date] }.reverse!
              @totals = Erp::Orders::Order.sales_details_report(@global_filters)[:total]
            end
          end
          
          File.open("tmp/report_sales_details_xlsx_#{current_user.id}.yml", "w+") do |f|
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
        
        # Xuat file excel //So chi tiet ban hang
        def report_sales_details_xlsx
          data = YAML.load_file("tmp/report_sales_details_xlsx_#{current_user.id}.yml")
          
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
              response.headers['Content-Disposition'] = 'attachment; filename="So chi tiet ban hang.xlsx"'
            }
          end
        end
        
        # Bao cao so luong ban hang
        def report_product_sold_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end
          
          @categories = Erp::Products::Category.includes(:children).where(children_erp_products_categories: {id: nil}).all_unarchive
        end
        
        def report_product_sold_xlsx
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end
          
          @categories = Erp::Products::Category.includes(:children).where(children_erp_products_categories: {id: nil}).all_unarchive
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao so luong ban hang.xlsx"'
            }
          end
        end

        # Bao cao hang ban bi tra lai
        def report_product_return_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end
          
          product_return_query = Erp::Qdeliveries::Delivery.all_delivered
            .sales_import_deliveries(from_date: @from, to_date: @to)
            .select('customer_id')

          # @todo chỉ lấy danh sách khách hàng nào có trả hàng trong thời gian lọc
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          @customers = @customers.where("erp_contacts_contacts.id IN (?)", product_return_query).order(:name)

          # get categories
          category_ids = glb[:categories].present? ? glb[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # len products
          @len_product_ids = Erp::Products::Product.where(category_id: Erp::Products::Category.get_lens.map(&:id)).select('id')
        end
        
        def report_product_return_xlsx
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end
          
          product_return_query = Erp::Qdeliveries::Delivery.all_delivered
            .sales_import_deliveries(from_date: @from, to_date: @to)
            .select('customer_id')

          # @todo chỉ lấy danh sách khách hàng nào có trả hàng trong thời gian lọc
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          @customers = @customers.where("erp_contacts_contacts.id IN (?)", product_return_query).order(:name)

          # get categories
          category_ids = glb[:categories].present? ? glb[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # len products
          @len_product_ids = Erp::Products::Product.where(category_id: Erp::Products::Category.get_lens.map(&:id)).select('id')
          
          
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao khach hang tra hang.xlsx"'
            }
          end
        end

        # Bao cao danh sach benh nhan moi
        def report_new_patient_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          liability_patient_ids = Erp::Contacts::Contact.get_patients_by_state(
            payment_for: Erp::Orders::Order::PAYMENT_FOR_CONTACT,
            patient_state_id: Erp::OrthoK::PatientState.get_new_patient.id,
            from: @from,
            to: @to
          ).map(&:patient_id).uniq


          retail_patient_ids = Erp::Contacts::Contact.get_patients_by_state(
            payment_for: Erp::Orders::Order::PAYMENT_FOR_ORDER,
            patient_state_id: Erp::OrthoK::PatientState.get_new_patient.id,
            from: @from,
            to: @to
          ).map(&:patient_id).uniq

          @liability_new_patients = Erp::Contacts::Contact.where(id: liability_patient_ids)
          @retail_new_patients = Erp::Contacts::Contact.where(id: retail_patient_ids)
          @total_new_patient = @liability_new_patients.count + @retail_new_patients.count
        end
        
        def report_new_patient_xlsx
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          liability_patient_ids = Erp::Contacts::Contact.get_patients_by_state(
            payment_for: Erp::Orders::Order::PAYMENT_FOR_CONTACT,
            patient_state_id: Erp::OrthoK::PatientState.get_new_patient.id,
            from: @from,
            to: @to
          ).map(&:patient_id).uniq


          retail_patient_ids = Erp::Contacts::Contact.get_patients_by_state(
            payment_for: Erp::Orders::Order::PAYMENT_FOR_ORDER,
            patient_state_id: Erp::OrthoK::PatientState.get_new_patient.id,
            from: @from,
            to: @to
          ).map(&:patient_id).uniq

          @liability_new_patients = Erp::Contacts::Contact.where(id: liability_patient_ids)
          @retail_new_patients = Erp::Contacts::Contact.where(id: retail_patient_ids)
          @total_new_patient = @liability_new_patients.count + @retail_new_patients.count
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao benh nhan phong kham moi.xlsx"'
            }
          end
        end
        
        # Bao cao danh sach benh nhan moi
        def report_new_patient_v2_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end
          
          if glb[:customer].present?
            @customer_ids = glb[:customer]
            @customers = Erp::Contacts::Contact.where(id: @customer_ids)
          end
        end
        
        def report_new_patient_v2_xlsx
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end
          
          if glb[:customer].present?
            @customer_ids = glb[:customer]
            @customers = Erp::Contacts::Contact.where(id: @customer_ids)
          end
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao benh nhan theo khach hang.xlsx"'
            }
          end
        end
        
        # Bao cao hang ban bi tra lai
        def report_product_return_by_pstate
          
        end
        
        # Bao cao hang ban bi tra lai
        def report_product_return_by_pstate_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period = Erp::Periods::Period.find(glb[:period])
            @from = @period.from_date.beginning_of_day
            @to = @period.to_date.end_of_day
          else
            @period = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end
          
          @customers = Erp::Contacts::Contact.get_has_sales_returned_qdeliveries(from_date: @from, to_date: @to)
          
          # get categories
          category_ids = glb[:categories].present? ? glb[:categories] : nil
          @categories = Erp::Products::Category.where(id: category_ids)

          # patients states
          patient_states = Erp::OrthoK::PatientState.get_active
          @patient_states = patient_states.map {|p| {name: p.name, id: p.id} }
          @patient_states << {name: 'Không chứng từ', id: -1}
          @patient_states << {name: 'Không có bệnh nhân', id: -2}
          
          # rows
          @rows = []
          @totals = {total: 0}
          @category_totals = {}
          
          @customers.each do |customer|
            row = {}
            
            # customer
            row[:customer] = customer
            row[:total] = 0            
            
            # by patient state
            @patient_states.each do |state|
              ddsq = Erp::Qdeliveries::DeliveryDetail.get_returned_confirmed_delivery_details(from_date: @from, to_date: @to, patient_state_id: state[:id])
                .joins(:product)
                .where(erp_qdeliveries_deliveries: {customer_id: customer.id})
                .where(erp_products_products: {category_id: Erp::Products::Category.get_lens.select(:id)})
              
              quantity = ddsq.sum(:quantity)
              
              row[state[:name]] = quantity
              row[:total] += quantity
              
              # totals
              @totals[state[:name]] = @totals[state[:name]].present? ? (@totals[state[:name]] + quantity) : quantity
              @totals[:total] += quantity
            end
            
            # orther product
            @categories.each do |category|
              product_ids = Erp::Products::Product.where(category_id: category.id).select('id')
              product_ids = -1 if product_ids.empty?
              quan = Erp::Products::Product.get_qdelivery_import({
                  product_id: product_ids,
                  from_date: @from,
                  to_date: @to,
                  delivery_type: [
                      Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT
                  ],
                  customer_id: customer.id
              })
              
              row[category.name] = quan
              
              @category_totals[category.name] = @category_totals[category.name].present? ? (@category_totals[category.name] + quan) : quan
            end
            
            @rows << row
          end
          
          File.open("tmp/report_product_return_by_pstate.yml", "w+") do |f|
            f.write({
              rows: @rows,
              category_totals: @category_totals,
              totals: @totals,
              from: @from,
              to: @to,
              patient_states: @patient_states,
              categories: @categories,
            }.to_yaml)
          end
        end
        
        def report_product_return_by_pstate_xlsx
          data = YAML.load_file("tmp/report_product_return_by_pstate.yml")
          
          @rows = data[:rows]
          @category_totals = data[:category_totals]
          @totals = data[:totals]
          @from_date = data[:from]
          @to_date = data[:to]
          @patient_states = data[:patient_states]
          @categories = data[:categories]
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao khach hang tra hang.xlsx"'
            }
          end
        end
      end
    end
  end
end
