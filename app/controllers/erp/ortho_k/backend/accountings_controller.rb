module Erp
  module OrthoK
    module Backend
      class AccountingsController < Erp::Backend::BackendController
        # Bao cao chi tiet thu/chi        
        def report_pay_receive_table
          @payment_records = Erp::Payments::PaymentRecord.search(params)
          
          @payment_records = @payment_records.where(
            payment_type_id: [
              Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_CUSTOMER).id,
              Erp::Payments::PaymentType.find_by_code(Erp::Payments::PaymentType::CODE_SALES_ORDER).id
            ]
          ).order('payment_date DESC')
        end
        
        # Bao cao tong hop thu/chi
        def report_synthesis_pay_receive_table
          # @todo: Bổ sung thêm để lấy ra các khoản thu/chi
          @payables = Erp::Payments::PaymentType.where(is_payable: true)
          @receivables = Erp::Payments::PaymentType.where(is_receivable: true)
        end
        
        # Bao cao ket qua ban hang
        def report_sales_results_table
          @sales_order_details = Erp::Orders::OrderDetail.joins(:order).where(erp_orders_orders: {status: Erp::Orders::Order::STATUS_CONFIRMED})
          @delivery_details = Erp::Qdeliveries::DeliveryDetail.joins(:delivery).where(erp_qdeliveries_deliveries: {delivery_type: Erp::Qdeliveries::Delivery::TYPE_CUSTOMER_IMPORT})
        end
        
        # Bao cao ket qua kinh doanh
        def report_income_statement_table
        end
        
        # Báo cáo dòng tiền còn lại cuối kỳ
        def report_cash_flow_table
          @accounts = Erp::Payments::Account.search(params)
        end
        
        # Bao cao cong no khach hang
        def report_customer_liabilities_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          if glb[:customer].present?
            @customers = Erp::Contacts::Contact.where(id: glb[:customer])
          else
            @customers = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
                                              .where(is_customer: true)
          end
          
          # Begin total
          @total_begin_period = 10000000

          # Period amount
          @total_period = 1000000

          # Recieved total
          @total_paid_period = 10000000

          # End of period amount
          @total_end_period = 1000000000
        end
        
        # Bao cao cong no nha cung cap
        def report_supplier_liabilities_table
          glb = params.to_unsafe_hash[:global_filter]
          if glb[:period].present?
            @from = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @from = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : Time.now.beginning_of_month
            @to = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          if glb[:supplier].present?
            @suppliers = Erp::Contacts::Contact.where(id: glb[:supplier])
          else
            @suppliers = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
                                              .where(is_supplier: true)
          end
        end
      end
    end
  end
end