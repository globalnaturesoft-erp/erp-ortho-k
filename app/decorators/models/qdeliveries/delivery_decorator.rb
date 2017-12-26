Erp::Qdeliveries::Delivery.class_eval do
  # get report name
  def get_report_name
    str = []
    str << customer_name if customer_name.present?
    str << note.to_s if note.present?
    return 'Hoàn kho - ' + str.join(" - ")
  end
end