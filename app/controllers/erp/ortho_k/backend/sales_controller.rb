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

        def report_sell_and_return_xlsx
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

          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = 'attachment; filename="Bao cao ban va tra hang.xlsx"'
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

          if @from_date.present? and @to_date.present?
            @rows = Erp::Orders::Order.sales_details_report(params)[:data]
            @totals = Erp::Orders::Order.sales_details_report(params)[:total]
          end

          render layout: nil
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
          
          @categories = Erp::Products::Category.top_categories.all_unarchive
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
          
          @categories = Erp::Products::Category.top_categories.all_unarchive
          
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

          # @todo chỉ lấy danh sách khách hàng nào có trả hàng trong thời gian lọc
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)

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
            @from_date = Erp::Periods::Period.find(glb[:period]).from_date.beginning_of_day
            @to_date = Erp::Periods::Period.find(glb[:period]).to_date.end_of_day
          else
            @period_name = nil
            @from_date = (glb.present? and glb[:from_date].present?) ? glb[:from_date].to_date : nil
            @to_date = (glb.present? and glb[:to_date].present?) ? glb[:to_date].to_date : nil
          end

          # @todo chỉ lấy danh sách khách hàng nào có trả hàng trong thời gian lọc
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)

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
