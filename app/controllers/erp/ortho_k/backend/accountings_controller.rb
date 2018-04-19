module Erp
  module OrthoK
    module Backend
      class AccountingsController < Erp::Backend::BackendController
        # Bao cao chi tiet thu/chi
        def report_pay_receive_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          @payment_records = Erp::Payments::PaymentRecord.search(params)

          @payment_records = @payment_records.where(
            payment_type_id: [
              Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id,
              Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER).id
            ]
          ).order('payment_date DESC')
        end

        def report_pay_receive_xlsx
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          @payment_records = Erp::Payments::PaymentRecord.search(params)

          @payment_records = @payment_records.where(
            payment_type_id: [
              Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id,
              Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER).id
            ]
          ).order('payment_date DESC')

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thu chi tien ban hang.xlsx"'
            }
          end
        end

        # Bao cao tong hop thu/chi
        def report_synthesis_pay_receive_table
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

          @payables = Erp::Payments::PaymentType.where(is_payable: true)
          @receivables = Erp::Payments::PaymentType.where(is_receivable: true)
          @payment_types = Erp::Payments::PaymentType.all # Lấy các payment type ACTIVE
        end

        def report_synthesis_pay_receive_xlsx
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

          @payables = Erp::Payments::PaymentType.where(is_payable: true)
          @receivables = Erp::Payments::PaymentType.where(is_receivable: true)
          @payment_types = Erp::Payments::PaymentType.all_active # Lấy các payment type ACTIVE

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thu chi tong hop.xlsx"'
            }
          end
        end

        # Bao cao ket qua ban hang
        def report_sales_results_table
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

          @categories = Erp::Products::Category.all_unarchive
        end

        def report_sales_results_xlsx
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

          @categories = Erp::Products::Category.all_unarchive
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Ket qua doanh thu ban hang.xlsx"'
            }
          end
        end

        # Bao cao ket qua kinh doanh
        def report_income_statement_table
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
          
          @payables = Erp::Payments::PaymentType.get_custom_payment_types.payables.order('name ASC')
          @receivables = Erp::Payments::PaymentType.get_custom_payment_types.receivables.order('name ASC')
        end

        def report_income_statement_xlsx
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
          
          @payables = Erp::Payments::PaymentType.get_custom_payment_types.payables
          @receivables = Erp::Payments::PaymentType.get_custom_payment_types.receivables
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Ket qua kinh doanh.xlsx"'
            }
          end
        end

        # Báo cáo dòng tiền còn lại cuối kỳ
        def report_cash_flow_table
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

          @accounts = Erp::Payments::Account.search(params) # .where('erp_payments_accounts.code LIKE ?', "1121%")
        end

        def report_cash_flow_xlsx
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

          @accounts = Erp::Payments::Account.search(params)

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao dong tien.xlsx"'
            }
          end
        end

        # Bao cao cong no khach hang
        def report_customer_liabilities_table
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date : nil #Time.now.beginning_of_month
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date : nil
          end
          
          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          if @global_filters[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: @global_filters[:customer])
          else
            @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          end
          
          # @todo only show related contacts, lien he co phat sinh moi show
          @customers = @customers.get_sales_payment_chasing_contacts(
            from_date: @from,
            to_date: @to
          )
          
          File.open("tmp/report_customer_liabilities_xlsx.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              customers: @customers
            }.to_yaml)
          end
        end

        def report_customer_liabilities_xlsx
          data = YAML.load_file("tmp/report_customer_liabilities_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date
          @to = data[:to_date].to_date
          @customers = data[:customers]
          
          @customers = Erp::Contacts::Contact.where(id: (@customers.map{|i| i.id}))

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao cong no khach hang.xlsx"'
            }
          end
        end

        # Bao cao cong no nha cung cap
        def report_supplier_liabilities_table
          global_filters = params.to_unsafe_hash[:global_filter]
          if global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(global_filters[:period]).name
            @from = Erp::Periods::Period.find(global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (global_filters.present? and global_filters[:from_date].present?) ? global_filters[:from_date].to_date : nil #Time.now.beginning_of_month
            @to = (global_filters.present? and global_filters[:to_date].present?) ? global_filters[:to_date].to_date : nil
          end

          if global_filters[:supplier].present?
            @suppliers = Erp::Contacts::Contact.where(id: global_filters[:supplier])
          else
            @suppliers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          end
          
          # @todo only show related contacts, lien he co phat sinh moi show
          @suppliers = @suppliers.get_purchase_payment_chasing_contacts(
            from_date: @from,
            to_date: @to
          )
          
          File.open("tmp/report_supplier_liabilities_xlsx.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              suppliers: @suppliers
            }.to_yaml)
          end
        end

        def report_supplier_liabilities_xlsx
          data = YAML.load_file("tmp/report_supplier_liabilities_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date
          @to = data[:to_date].to_date
          @suppliers = data[:suppliers]
          
          @suppliers = Erp::Contacts::Contact.where(id: (@suppliers.map{|i| i.id}))

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao cong no nha cung cap.xlsx"'
            }
          end
        end
        
        # Thong ke tong cong no khach hang
        def report_statistics_liabilities_table
          @periods = Erp::Periods::Period.get_time_array(params)
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
        end

        def report_statistics_liabilities_xlsx
          @periods = Erp::Periods::Period.get_time_array(params)
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke cong no khach hang.xlsx"'
            }
          end
        end
        
        # Bao cao cong no co phat sinh
        def report_liabilities_arising_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil #Time.now.beginning_of_month
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          if glb[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: glb[:customer])
          else
            @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          end
          
          # Loc danh sach cac khach hang co phat sinh giao dich (thanh toan, cong no)
          order_query = Erp::Orders::Order.all_confirmed
            .sales_orders
            .payment_for_contact_orders(from_date: @from, to_date: @to)
            .select('customer_id')
          
          product_return_query = Erp::Qdeliveries::Delivery.all_delivered
            .sales_import_deliveries
            .get_deliveries_with_payment_for_contact(from_date: @from, to_date: @to)
            .select('customer_id')
          
          payment_query = Erp::Payments::PaymentRecord.all_done
            .select('customer_id')
            .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id)
            .where("payment_date >= ? AND payment_date <= ?", @from, @to)
          
          @customers = @customers.where("id IN (?) OR id IN (?) OR id IN (?)", order_query, product_return_query, payment_query)
          
        end

        def report_liabilities_arising_xlsx
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @period_name = Erp::Periods::Period.find(glb[:period]).name
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil #Time.now.beginning_of_month
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          if glb[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: glb[:customer])
          else
            @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          end
          
          # Loc danh sach cac khach hang co phat sinh giao dich (thanh toan, cong no)
          order_query = Erp::Orders::Order.all_confirmed
            .sales_orders
            .payment_for_contact_orders(from_date: @from, to_date: @to)
            .select('customer_id')
          
          product_return_query = Erp::Qdeliveries::Delivery.all_delivered
            .sales_import_deliveries
            .get_deliveries_with_payment_for_contact(from_date: @from, to_date: @to)
            .select('customer_id')
          
          payment_query = Erp::Payments::PaymentRecord.all_done
            .select('customer_id')
            .where(payment_type_id: Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id)
            .where("payment_date >= ? AND payment_date <= ?", @from, @to)
          
          @customers = @customers.where("id IN (?) OR id IN (?) OR id IN (?)", order_query, product_return_query, payment_query)

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao khach hang phat sinh.xlsx"'
            }
          end
        end
        
        # Sales summary
        def report_sales_summary
        end
        # Sales summary table
        def report_sales_summary_table
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
          
          # repaired data
          @data = {
            sales: {
              rows: [],
              total: {
                quantity: 0,
                amount: 0.0
              }
            },
            returns: {
              rows: [],
              total: {
                quantity: 0,
                amount: 0.0
              }
            },
            total: {
              quantity: 0,
              amount: 0.0
            },
            from: @from,
            to: @to
          }
          
          # sales table
          
          # by patient state
          patient_states = Erp::OrthoK::PatientState.get_active
          patient_states.each do |pst|
            
            odsq = Erp::Orders::OrderDetail.get_sales_confirmed_order_details(from_date: @from, to_date: @to, patient_state_id: pst.id)
              .joins(:product)
              .where(erp_products_products: {category_id: Erp::Products::Category.get_lens.select(:id)})
            
            quantity = odsq.sum(:quantity)
            amount = odsq.sum(&:total_without_tax)
            
            if quantity + amount > 0
              @data[:sales][:rows] << {
                name: "Len (#{pst.name})",
                quantity: quantity,
                amount: amount
              }
              
              @data[:sales][:total][:quantity] += quantity
              @data[:sales][:total][:amount] += amount
            end
          end
          
          # other products
          not_len_products = Erp::Products::Product.get_sales_products_not_len(from_date: @from, to_date: @to)          
          not_len_products.each do |p|
            odsq = p.get_sales_confirmed_order_details
            
            quantity = odsq.sum(:quantity)
            amount = odsq.sum(&:total_without_tax)
            
            if quantity + amount > 0
              @data[:sales][:rows] << {
                name: p.name,
                quantity: quantity,
                amount: amount
              }
              
              @data[:sales][:total][:quantity] += quantity
              @data[:sales][:total][:amount] += amount
            end
          end
          
          # returns table
          patient_states = Erp::OrthoK::PatientState.get_active
          patient_states.each do |pst|
            
            ddsq = Erp::Qdeliveries::DeliveryDetail.get_returned_confirmed_delivery_details(from_date: @from, to_date: @to, patient_state_id: pst.id)
              .joins(:product)
              .where(erp_products_products: {category_id: Erp::Products::Category.get_lens.select(:id)})
            
            quantity = ddsq.sum(:quantity)
            amount = ddsq.sum(&:total_amount)
            
            if quantity + amount > 0
              @data[:returns][:rows] << {
                name: "Len (#{pst.name})",
                quantity: quantity,
                amount: amount
              }
              
              @data[:returns][:total][:quantity] += quantity
              @data[:returns][:total][:amount] += amount
            end
          end
          
          # other products
          not_len_products = Erp::Products::Product.get_returned_products_not_len(from_date: @from, to_date: @to)          
          not_len_products.each do |p|
            ddsq = p.get_returned_confirmed_delivery_details
            
            quantity = ddsq.sum(:quantity)
            amount = ddsq.sum(&:total_amount)
            
            if quantity + amount > 0
              @data[:returns][:rows] << {
                name: p.name,
                quantity: quantity,
                amount: amount
              }
              
              @data[:returns][:total][:quantity] += quantity
              @data[:returns][:total][:amount] += amount
            end
          end
          
          File.open("tmp/report_sales_summary.yml", "w+") do |f|
            f.write(@data.to_yaml)
          end
          
        end
        # Sales summary excel
        def report_sales_summary_xlsx
          @data = YAML.load_file("tmp/report_sales_summary.yml")
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke ban hang.xlsx"'
            }
          end
        end
      end
    end
  end
end
