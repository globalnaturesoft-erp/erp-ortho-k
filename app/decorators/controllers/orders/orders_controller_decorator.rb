Erp::Orders::Backend::OrdersController.class_eval do
  # get related contact form
  def related_contact_form
    if !params.to_unsafe_hash[:datas].present?
      render plain: 'sss'
    else
      @contact = Erp::Contacts::Contact.find(params.to_unsafe_hash[:datas][0])
    end
  end
end
