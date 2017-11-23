module Erp
  module OrthoK
    module Backend
      class SalesController < Erp::Backend::BackendController
        # Bao cao ban va tra hang
        def report_sell_and_return_table
          @orders = Erp::Orders::Order.sales_orders
          @deliveries = Erp::Qdeliveries::Delivery.where(delivery_type: Erp::Qdeliveries::Delivery::TYPE_CUSTOMER_IMPORT)
        end
        
        # So chi tiet ban hang
        def report_sales_details_table
          
        end
        
        # So chi tiet ban hang
        def report_product_return_table
          @customers = Erp::Contacts::Contact.where.not(id: Erp::Contacts::Contact.get_main_contact.id)
        end
        
        # Bao cao danh sach benh nhan moi
        def report_new_patient_table
          liability_patient_ids = Erp::Orders::Order.where(payment_for: Erp::Orders::Order::PAYMENT_FOR_CONTACT)
                                                    .where.not(patient_id: nil)
                                                    .where(is_new_patient: true)
                                                    .map(&:patient_id).uniq
          retail_patient_ids = Erp::Orders::Order.where(payment_for: Erp::Orders::Order::PAYMENT_FOR_ORDER)
                                                    .where.not(patient_id: nil)
                                                    .where(is_new_patient: true)
                                                    .map(&:patient_id).uniq
          
          @liability_new_patients = Erp::Contacts::Contact.where(id: liability_patient_ids)
          @retail_new_patients = Erp::Contacts::Contact.where(id: retail_patient_ids)
          @total_new_patient = @liability_new_patients.count + @retail_new_patients.count
        end
      end
    end
  end
end