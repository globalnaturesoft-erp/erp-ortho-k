Erp::Qdeliveries::DeliveryDetail.class_eval do
  # get report name
  def get_report_name
    str = []
    str << get_order.doctor_name if get_order.present? and get_order.doctor_name.present?
    str << ('BN' + ((' ' + get_order.patient_state_name) if get_order.patient_state_name.present?) + ': ' + get_order.patient_name) if get_order.patient_name.present?
    str << get_order_code if !order_detail.nil?
    str << get_order.order_date.strftime("%d/%m/%Y") if !order_detail.nil?
    str << state_name if state_name.present?
    return str.join(" - ")
  end
end
