Erp::Orders::Backend::OrdersController.class_eval do
  # get related contact form
  def related_contact_form
    if !params.to_unsafe_hash[:datas].present?
      render plain: ''
    else
      @contact = Erp::Contacts::Contact.where(id: params.to_unsafe_hash[:datas][0]).first

      if @contact.present?
        if params.to_unsafe_hash[:order_id].present?
          @order = Erp::Orders::Order.find(params.to_unsafe_hash[:order_id])
        else
          @order = Erp::Orders::Order.new
        end
      else
        render plain: ''
      end
    end
  end
end
