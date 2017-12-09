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
          @payment_types = Erp::Payments::PaymentType.all # Lấy các payment type ACTIVE

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
            #@todo only show related contacts, lien he co phat sinh moi show
            @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          end
        end

        def report_customer_liabilities_xlsx
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
            #@todo only show related contacts, lien he co phat sinh moi show
            @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
          end

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Cong no khach hang.xlsx"'
            }
          end
        end

        # Bao cao cong no nha cung cap
        def report_supplier_liabilities_table
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

          if glb[:supplier].present?
            @suppliers = Erp::Contacts::Contact.where(id: glb[:supplier])
          else
            @suppliers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
                          #.where(is_supplier: true)
          end
        end

        def report_supplier_liabilities_xlsx
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

          if glb[:supplier].present?
            @suppliers = Erp::Contacts::Contact.where(id: glb[:supplier])
          else
            @suppliers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
                          #.where(is_supplier: true)
          end

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Cong no nha cung cap.xlsx"'
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
      end
    end
  end
end
