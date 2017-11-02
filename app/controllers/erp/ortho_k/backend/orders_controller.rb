module Erp
  module OrthoK
    module Backend
      class OrdersController < Erp::Backend::BackendController
        # Matrix report
        def patient_info
          @contact = Erp::Contacts::Contact.where(id: params[:datas][0]).first
          @orders = @contact.present? ? @contact.patient_orders : []
        end
      end
    end
  end
end
