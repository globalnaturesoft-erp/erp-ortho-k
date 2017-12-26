Erp::Payments::Backend::PaymentRecordsController.class_eval do
  def xlsx_export_liabilities
    @from = (params[:from_date].present?) ? params[:from_date].to_date : Time.now.beginning_of_month
    @to = (params[:to_date].present?) ? params[:to_date].to_date : Time.now

    @customer = Erp::Contacts::Contact.find(params[:customer_id])
    @orders = @customer.sales_orders.payment_for_contact_orders(params.to_unsafe_hash)
    @product_returns = @customer.sales_product_returns.get_deliveries_with_payment_for_contact(params.to_unsafe_hash)
    
    respond_to do |format|
      format.xlsx {
        response.headers['Content-Disposition'] = 'attachment; filename="Bang cong no khach hang.xlsx"'
      }
    end
  end
end