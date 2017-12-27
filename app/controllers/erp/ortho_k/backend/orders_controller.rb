module Erp
  module OrthoK
    module Backend
      class OrdersController < Erp::Backend::BackendController
        # Matrix report
        def patient_info
          @contact = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          @orders = @contact.present? ? @contact.patient_orders : []
        end

        # Change order checking order
        def change_checking_order
          order = Erp::Orders::Order.find(params[:id])
          checking_order = (order.checking_order > params[:order].to_f ? params[:order].to_f - 0.5 : params[:order].to_f + 0.5)

          order.update_column(:checking_order, checking_order)
          Erp::Orders::Order.update_checking_order

          render json: {
            status: 'success',
            text: 'Cập nhật thứ tự kiểm tra thành công',
          }
        end
      end
    end
  end
end
