module Erp
  module OrthoK
    module Backend
      class AccountingsController < Erp::Backend::BackendController
        # Bao cao chi tiet thu/chi
        def report_pay_receive
          authorize! :report_accounting_pay_receive, nil
        end
        
        def report_pay_receive_table
          authorize! :report_accounting_pay_receive, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date.beginning_of_day : nil
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date.end_of_day : nil
          end

          @payment_records = Erp::Payments::PaymentRecord.all_done.search(params)

          @payment_records = @payment_records.where(
            payment_type_id: [
              Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id,
              Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER).id
            ]
          ).order('erp_payments_payment_records.payment_date ASC')
          
          File.open("tmp/report_pay_receive_xlsx.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              payment_records: @payment_records
            }.to_yaml)
          end
        end

        def report_pay_receive_xlsx
          authorize! :report_accounting_pay_receive, nil
          
          data = YAML.load_file("tmp/report_pay_receive_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date
          @to = data[:to_date].to_date
          @payment_records = data[:payment_records]
          
          @payment_records = Erp::Payments::PaymentRecord.where(id: (@payment_records.map{|i| i.id})).order('payment_date ASC')

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thu chi tien ban hang.xlsx"'
            }
          end
        end

        # Bao cao tong hop thu/chi
        def report_synthesis_pay_receive
          authorize! :report_accounting_synthesis_pay_receive, nil
        end
        
        def report_synthesis_pay_receive_table
          authorize! :report_accounting_synthesis_pay_receive, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date.beginning_of_day : nil
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date.end_of_day : nil
          end

          @payment_types = Erp::Payments::PaymentType.all_active
          @payables = @payment_types.where(is_payable: true).order('erp_payments_payment_types.name ASC')
          @receivables = @payment_types.where(is_receivable: true).order('erp_payments_payment_types.name ASC')
          
          File.open("tmp/report_synthesis_pay_receive_xlsx.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              payables: @payables,
              receivables: @receivables,
              payment_types: @payment_types
            }.to_yaml)
          end
        end

        def report_synthesis_pay_receive_xlsx
          authorize! :report_accounting_synthesis_pay_receive, nil
          
          data = YAML.load_file("tmp/report_synthesis_pay_receive_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date
          @to = data[:to_date].to_date
          @payment_types = data[:payment_types]
          @payables = data[:payables]
          @receivables = data[:receivables]
          
          @payment_types = Erp::Payments::PaymentType.where(id: (@payment_types.map{|i| i.id}))
          @payables = @payment_types.where(id: (@payables.map{|i| i.id})).order('erp_payments_payment_types.name ASC')
          @receivables = @payment_types.where(id: (@receivables.map{|i| i.id})).order('erp_payments_payment_types.name ASC')

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thu chi tong hop.xlsx"'
            }
          end
        end

        # Bao cao ket qua ban hang
        def report_sales_results
          authorize! :report_accounting_sales_results, nil
        end
        
        def report_sales_results_table
          authorize! :report_accounting_sales_results, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date.beginning_of_day : nil
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date.end_of_day : nil
          end

          @categories = Erp::Products::Category.all_unarchive
            .order('erp_products_categories.name ASC')
          
          File.open("tmp/report_sales_results_xlsx.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              categories: @categories
            }.to_yaml)
          end
        end

        def report_sales_results_xlsx
          authorize! :report_accounting_sales_results, nil
          
          data = YAML.load_file("tmp/report_sales_results_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date
          @to = data[:to_date].to_date
          @categories = data[:categories]
          
          @categories = Erp::Products::Category.where(id: (@categories.map{|i| i.id}))
            .order('erp_products_categories.name ASC')
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Ket qua doanh thu ban hang.xlsx"'
            }
          end
        end

        # Bao cao ket qua kinh doanh
        def report_income_statement
          authorize! :report_accounting_income_statement, nil
        end
        
        def report_income_statement_table
          authorize! :report_accounting_income_statement, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date.beginning_of_day : nil
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date.end_of_day : nil
          end
          
          @payables = Erp::Payments::PaymentType.get_custom_payment_types.payables.order('erp_payments_payment_types.name ASC')
          @receivables = Erp::Payments::PaymentType.get_custom_payment_types.receivables.order('erp_payments_payment_types.name ASC')
          
          File.open("tmp/report_income_statement_xlsx.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              payables: @payables,
              receivables: @receivables
            }.to_yaml)
          end
        end

        def report_income_statement_xlsx
          authorize! :report_accounting_income_statement, nil
          
          data = YAML.load_file("tmp/report_income_statement_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date
          @to = data[:to_date].to_date
          @payables = data[:payables]
          @receivables = data[:receivables]
          
          @payables = Erp::Payments::PaymentType.where(id: (@payables.map{|i| i.id})).order('erp_payments_payment_types.name ASC')
          @receivables = Erp::Payments::PaymentType.where(id: (@receivables.map{|i| i.id})).order('erp_payments_payment_types.name ASC')
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Ket qua kinh doanh.xlsx"'
            }
          end
        end

        # Báo cáo dòng tiền còn lại cuối kỳ
        def report_cash_flow
          authorize! :report_accounting_cash_flow, nil
        end
        
        def report_cash_flow_table
          authorize! :report_accounting_cash_flow, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date.beginning_of_day : nil
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date.end_of_day : nil
          end

          @accounts = Erp::Payments::Account.all_active.search(params).order('erp_payments_accounts.name ASC') # .where('erp_payments_accounts.code LIKE ?', "1121%")
          
          File.open("tmp/report_cash_flow_xlsx.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              accounts: @accounts
            }.to_yaml)
          end
        end

        def report_cash_flow_xlsx
          authorize! :report_accounting_cash_flow, nil
          
          data = YAML.load_file("tmp/report_cash_flow_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date
          @to = data[:to_date].to_date
          @accounts = data[:accounts]
          
          @accounts = Erp::Payments::Account.where(id: (@accounts.map{|i| i.id})).order('erp_payments_accounts.name ASC')

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao dong tien.xlsx"'
            }
          end
        end

        # Bao cao cong no khach hang
        def report_customer_liabilities
          authorize! :report_accounting_customer_liabilities, nil
        end
        
        def report_customer_liabilities_table
          authorize! :report_accounting_customer_liabilities, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date.beginning_of_day : nil #Time.now.beginning_of_month
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date.end_of_day : nil
          end
          
          @from_date = @global_filters[:from_date].to_date
          @to_date = @global_filters[:to_date].to_date

          if @global_filters[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: @global_filters[:customer])
          else
            @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          end
          
          #@customers = @customers.get_sales_payment_chasing_contacts#(from_date: @from, to_date: @to) # có phát sinh
          @customers = @customers.get_sales_liabilities_contacts(from_date: @from, to_date: @to) # còn nợ và có phát sinh
          
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
          authorize! :report_accounting_customer_liabilities, nil
          
          data = YAML.load_file("tmp/report_customer_liabilities_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date.beginning_of_day
          @to = data[:to_date].to_date.end_of_day
          @customers = data[:customers]
          
          @customers = Erp::Contacts::Contact.where(id: (@customers.map{|i| i.id}))

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao cong no khach hang.xlsx"'
            }
          end
        end

        # Bao cao cong no nha cung cap
        def report_supplier_liabilities
          authorize! :report_accounting_supplier_liabilities, nil
        end
        
        def report_supplier_liabilities_table
          authorize! :report_accounting_supplier_liabilities, nil
          
          global_filters = params.to_unsafe_hash[:global_filter]
          if global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(global_filters[:period]).name
            @from = Erp::Periods::Period.find(global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (global_filters.present? and global_filters[:from_date].present?) ? global_filters[:from_date].to_date.beginning_of_day : nil #Time.now.beginning_of_month
            @to = (global_filters.present? and global_filters[:to_date].present?) ? global_filters[:to_date].to_date.end_of_day : nil
          end

          if global_filters[:supplier].present?
            @suppliers = Erp::Contacts::Contact.where(id: global_filters[:supplier])
          else
            @suppliers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          end
          
          @suppliers = @suppliers.get_purchase_payment_chasing_contacts(from_date: @from, to_date: @to) # có phát sinh
          #@suppliers = @suppliers.get_purchase_liabilities_contacts(from_date: @from, to_date: @to) # còn nợ và có phát sinh
          
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
          authorize! :report_accounting_supplier_liabilities, nil
          
          data = YAML.load_file("tmp/report_supplier_liabilities_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date.beginning_of_day
          @to = data[:to_date].to_date.end_of_day
          @suppliers = data[:suppliers]
          
          @suppliers = Erp::Contacts::Contact.where(id: (@suppliers.map{|i| i.id}))

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao cong no nha cung cap.xlsx"'
            }
          end
        end
        
        # Thong ke tong cong no khach hang
        def report_statistics_liabilities
          authorize! :report_accounting_statistics_liabilities, nil
        end
        
        def report_statistics_liabilities_table
          authorize! :report_accounting_statistics_liabilities, nil
          
          @periods = Erp::Periods::Period.get_time_array(params)
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          
          File.open("tmp/report_statistics_liabilities_xlsx.yml", "w+") do |f|
            f.write({
              periods: @periods,
              customers: @customers
            }.to_yaml)
          end
        end

        def report_statistics_liabilities_xlsx
          authorize! :report_accounting_statistics_liabilities, nil
          
          data = YAML.load_file("tmp/report_statistics_liabilities_xlsx.yml")
          
          @periods = data[:periods]
          @customers = data[:customers]
          
          @customers = Erp::Contacts::Contact.where(id: (@customers.map{|i| i.id}))

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke cong no khach hang.xlsx"'
            }
          end
        end
        
        # Bao cao cong no co phat sinh
        def report_liabilities_arising
          authorize! :report_accounting_liabilities_arising, nil
        end
        
        def report_liabilities_arising_table
          authorize! :report_accounting_liabilities_arising, nil
          
          @global_filters = params.to_unsafe_hash[:global_filter]
          if @global_filters[:period].present?
            @period_name = Erp::Periods::Period.find(@global_filters[:period]).name
            @from = Erp::Periods::Period.find(@global_filters[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(@global_filters[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from = (@global_filters.present? and @global_filters[:from_date].present?) ? @global_filters[:from_date].to_date.beginning_of_day : nil #Time.now.beginning_of_month
            @to = (@global_filters.present? and @global_filters[:to_date].present?) ? @global_filters[:to_date].to_date.end_of_day : nil
          end

          if @global_filters[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: @global_filters[:customer])
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
                        .order("erp_contacts_contacts.name ASC")
          
          File.open("tmp/report_liabilities_arising_xlsx.yml", "w+") do |f|
            f.write({
              global_filters: @global_filters,
              period_name: @period_name,
              from_date: @from,
              to_date: @to,
              customers: @customers
            }.to_yaml)
          end
          
        end

        def report_liabilities_arising_xlsx
          authorize! :report_accounting_liabilities_arising, nil
          
          data = YAML.load_file("tmp/report_liabilities_arising_xlsx.yml")
          
          @global_filters = data[:global_filters]
          @period_name = data[:period_name]
          @from = data[:from_date].to_date
          @to = data[:to_date].to_date
          @customers = data[:customers]
          
          @customers = Erp::Contacts::Contact.where(id: (@customers.map{|i| i.id})).order("erp_contacts_contacts.name ASC")

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao khach hang phat sinh.xlsx"'
            }
          end
        end
        
        # Sales summary
        def report_sales_summary
          authorize! :report_accounting_sales_summary, nil
        end
        
        # Sales summary table
        def report_sales_summary_table
          authorize! :report_accounting_sales_summary, nil
          
          glb = params.to_unsafe_hash[:global_filter]
          if (glb[:from_date].present? && glb[:to_date].present?) || glb[:period].present?
            if glb[:period].present?
              @period = Erp::Periods::Period.find(glb[:period])
              @from = @period.from_date.beginning_of_day
              @to = @period.to_date.end_of_day
            else
              @period = nil
              @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date.beginning_of_day : nil
              @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date.end_of_day : nil
            end
            
            customers = Erp::Contacts::Contact.all
            customer_ids = customers.map{|i| i.id}
            if glb[:customer_group].present?
              if glb[:customer_group] == Erp::Products::Product::CONTACT_GROUPS_FARGO_HN
                customer_ids = customers.where(id: 128).map{|i| i.id}
                @customer_name = customers.find(128).name
              elsif glb[:customer_group] == Erp::Products::Product::CONTACT_GROUPS_NOT_FARGO_HN
                customer_ids = customers.where.not(id: 128).map{|i| i.id}
                @customer_name = 'Khách hàng khác'
              else
                customer_ids = customers.map{|i| i.id}
              end
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
            patient_states = Erp::OrthoK::PatientState.all
            pst_ids = patient_states.map {|p| {name: p.name, id: p.id} }
            pst_ids << {name: 'Không có bệnh nhân', id: -1}
            pst_ids.each do |pst|
              
              odsq = Erp::Orders::OrderDetail.get_sales_confirmed_order_details(from_date: @from, to_date: @to, patient_state_id: pst[:id], customer_id: customer_ids)
                .joins(:product)
                .where(erp_products_products: {category_id: Erp::Products::Category.get_lens.select(:id)})
              
              quantity = odsq.sum(:quantity)
              amount = odsq.sum(&:total_without_tax)
              
              if quantity + amount > 0
                @data[:sales][:rows] << {
                  name: "Len (#{pst[:name]})",
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
              odsq = p.get_sales_confirmed_order_details(from_date: @from, to_date: @to, customer_id: customer_ids) 
              
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
            pst_ids = patient_states.map {|p| {name: p.name, id: p.id} }
            pst_ids << {name: 'Không chứng từ', id: -1}
            pst_ids << {name: 'Không có bệnh nhân', id: -2}
            pst_ids.each do |pst|
              
              ddsq = Erp::Qdeliveries::DeliveryDetail.get_returned_confirmed_delivery_details(from_date: @from, to_date: @to, patient_state_id: pst[:id], customer_id: customer_ids)
                .joins(:product)
                .where(erp_products_products: {category_id: Erp::Products::Category.get_lens.select(:id)})
              
              quantity = ddsq.sum(:quantity)
              amount = ddsq.sum(&:total_amount)
              
              if quantity + amount > 0
                @data[:returns][:rows] << {
                  name: "Len (#{pst[:name]})",
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
              ddsq = p.get_returned_confirmed_delivery_details(from_date: @from, to_date: @to, customer_id: customer_ids)         
              
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
              f.write({
                data: @data,
                customer_name: @customer_name
              }.to_yaml)
            end
          end
        end
        
        # Sales summary excel
        def report_sales_summary_xlsx
          authorize! :report_accounting_sales_summary, nil
          
          dt = YAML.load_file("tmp/report_sales_summary.yml")
          
          @data = dt[:data]
          @customer_name = dt[:customer_name]
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke ban hang.xlsx"'
            }
          end
        end
        
        # Statistical donated goods
        def report_statistical_donated_goods
          ##authorize! :report_statistical_donated_goods, nil
        end
        
        # Statistical donated goods table
        def report_statistical_donated_goods_table
          #authorize! :report_statistical_donated_goods, nil
          
          glb = params.to_unsafe_hash[:global_filter]
          if (glb[:from_date].present? && glb[:to_date].present?) || glb[:period].present?
            if glb[:period].present?
              @period = Erp::Periods::Period.find(glb[:period])
              @from = @period.from_date.beginning_of_day
              @to = @period.to_date.end_of_day
            else
              @period = nil
              @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date.beginning_of_day : nil
              @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date.end_of_day : nil
            end
            
            if glb[:contact].present?
              @contacts = Erp::Contacts::Contact.where(id: glb[:contact])
            else
              @contacts = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
            end
            
            contact_ids = @contacts.map{|i| i.id}
            
            # repaired data
            @data = {
              gift: {
                rows: [],
                total: {
                  quantity: 0
                }
              },
              total: {
                quantity: 0
              },
              from: @from,
              to: @to
            }
            
            # other products
            products = Erp::Products::Product.get_gift_given_products(from_date: @from, to_date: @to)          
            products.each do |p|
              ggdt = p.get_gift_given_delivered_given_details(from_date: @from, to_date: @to, contact_id: contact_ids) 
              
              quantity = ggdt.sum(:quantity)
              
              if quantity > 0
                @data[:gift][:rows] << {
                  name: p.name,
                  quantity: quantity
                }
                
                @data[:gift][:total][:quantity] += quantity
              end
            end
            
            File.open("tmp/report_statistical_donated_goods.yml", "w+") do |f|
              f.write({
                data: @data
              }.to_yaml)
            end
          end
        end
        
        # Statistical donated goods excel
        def report_statistical_donated_goods_xlsx
          #authorize! :report_statistical_donated_goods, nil
          
          dt = YAML.load_file("tmp/report_statistical_donated_goods.yml")
          
          @data = dt[:data]
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Thong ke hang tang.xlsx"'
            }
          end
        end
        
        def report_customer_remaining_liabilities_by_monthly
          authorize! :report_accounting_customer_remaining_liabilities_by_monthly, nil
        end
        
        def report_customer_remaining_liabilities_by_monthly_table
          authorize! :report_accounting_customer_remaining_liabilities_by_monthly, nil
          
          global_filters = params.to_unsafe_hash[:global_filter]
          
          if global_filters[:period].present?
            period = Erp::Periods::Period.find(global_filters[:period])
            global_filters[:from_date] = period.from_date
            global_filters[:to_date] = period.to_date
            @period_name = period.name
          end
          
          if global_filters[:from_date].present? and global_filters[:to_date].present?
            @from_date = global_filters[:from_date].to_date
            @to_date = global_filters[:to_date].to_date
            
            @times = []
            @time = @from_date
            
            while @time <= @to_date.end_of_month
              @times << @time.end_of_month
              @time += 1.month
            end
            
            @report = {
              header: [],
              rows: [],
              footer: []
            }
            
            # add header
            @report[:header] << 'STT'
            @report[:header] << 'Tên khách hàng'
            @times.each do |time|
              @report[:header] << "T#{time.month}/#{time.year}"
            end
            @report[:header] << 'Hiện đang nợ'
            @report[:header] << 'N.viên ph.trách'
            
            if global_filters[:customer].present?
              @contacts = Erp::Contacts::Contact.where(id: global_filters[:customer])
            else
              @contacts = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
            end
            
            if global_filters[:contact_group_id].present?
              @contacts = @contacts.where(contact_group_id: global_filters[:contact_group_id])
            end
            
            if global_filters[:salesperson_id].present?
              @contacts = @contacts.where(salesperson_id: global_filters[:salesperson_id])
            end
            
            @contacts = @contacts.get_sales_debt_amount_residual_contacts.order('erp_contacts_contacts.name ASC') # đang còn công nợ đến nay
            #@contacts = @contacts.get_sales_payment_chasing_contacts(from_date: @from, to_date: @to) # có phát sinh trong kỳ
            #@contacts = @contacts.get_sales_liabilities_contacts(from_date: @from_date, to_date: @to_date) # đang còn công nợ đến nay và có phát sinh trong kỳ
            
            # add row
            @contacts.each_with_index do |contact,index|
              row = []
              
              row << (index + 1)
              row << contact.name
              @times.each do |time|
                row << contact.sales_debt_by_period_amount(to_date: time)
              end
              row << contact.cache_sales_debt_amount
              row << contact.salesperson_name
              
              @report[:rows] << row
            end
            
            # add footer
            @report[:footer] << 'Tổng cộng'
            @times.each do |time|
              @report[:footer] << @contacts.sales_debt_by_period_amount(to_date: time)
            end
            @report[:footer] << @contacts.cache_sales_debt_amount
            @report[:footer] << nil
            
            File.open("tmp/report_customer_remaining_liabilities_by_monthly_xlsx.yml", "w+") do |f|
              f.write({
                from_date: @from_date,
                to_date: @to_date,
                report: @report
              }.to_yaml)
            end
          end
        end
        
        def report_customer_remaining_liabilities_by_monthly_xlsx
          authorize! :report_accounting_customer_remaining_liabilities_by_monthly, nil
          
          data = YAML.load_file("tmp/report_customer_remaining_liabilities_by_monthly_xlsx.yml")
          
          @from_date = data[:from_date]
          @to_date = data[:to_date]
          
          @report = data[:report]

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao khach hang con no theo thang.xlsx"'
            }
          end
        end
      end
    end
  end
end
