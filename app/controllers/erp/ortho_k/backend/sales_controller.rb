module Erp
  module OrthoK
    module Backend
      class SalesController < Erp::Backend::BackendController
        # Bao cao ban va tra hang
        def report_sell_and_return_table
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

          @orders = Erp::Orders::Order.sales_orders.all_confirmed.search(params)

          @deliveries = Erp::Qdeliveries::Delivery.all_delivered.search(params)
                          .where(delivery_type: Erp::Qdeliveries::Delivery::TYPE_SALES_IMPORT)
        end

        # So chi tiet ban hang
        def report_sales_details_table
          @rows = Erp::Orders::Order.sales_details_report(params)[:data]
          @totals = Erp::Orders::Order.sales_details_report(params)[:total]

          render layout: nil
        end

        # So chi tiet ban hang
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

          # @todo chỉ lấy danh sách khách hàng nào có trả hàng trong thời gian lọc
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
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

          liability_patient_ids = Erp::Orders::Order.all_confirmed.where(payment_for: Erp::Orders::Order::PAYMENT_FOR_CONTACT)
                                                    .where.not(patient_id: nil)
                                                    .where(patient_state_id: Erp::OrthoK::PatientState.get_new_patient.id)
          if @from.present?
            liability_patient_ids = liability_patient_ids.where('order_date >= ?', @from.beginning_of_day)
          end

          if @to.present?
            liability_patient_ids = liability_patient_ids.where('order_date <= ?', @to.end_of_day)
          end

          liability_patient_ids = liability_patient_ids.map(&:patient_id).uniq


          retail_patient_ids = Erp::Orders::Order.all_confirmed.where(payment_for: Erp::Orders::Order::PAYMENT_FOR_ORDER)
                                                    .where.not(patient_id: nil)
                                                    .where(patient_state_id: Erp::OrthoK::PatientState.get_new_patient.id)

          if @from.present?
            retail_patient_ids = retail_patient_ids.where('order_date >= ?', @from.beginning_of_day)
          end

          if @to.present?
            retail_patient_ids = retail_patient_ids.where('order_date <= ?', @to.end_of_day)
          end

          retail_patient_ids = retail_patient_ids.map(&:patient_id).uniq

          @liability_new_patients = Erp::Contacts::Contact.where(id: liability_patient_ids)
          @retail_new_patients = Erp::Contacts::Contact.where(id: retail_patient_ids)
          @total_new_patient = @liability_new_patients.count + @retail_new_patients.count
        end
      end
    end
  end
end
