Erp::Consignments::ConsignmentDetail.class_eval do
  # get all active given details
  def self.get_consignment_delivered_consignment_details(options={})
    query = Erp::Consignments::ConsignmentDetail.joins(:consignment)
      .where(erp_consignments_consignments: {status: Erp::Consignments::Consignment::STATUS_DELIVERED})
  
    if options[:from_date].present?
      query = query.where('erp_consignments_consignments.sent_date >= ?', options[:from_date].to_date.beginning_of_day)
    end
  
    if options[:to_date].present?
      query = query.where('erp_consignments_consignments.sent_date <= ?', options[:to_date].to_date.end_of_day)
    end
  
    if options[:contact_id].present?
      query = query.where(erp_consignments_consignments: {contact_id: options[:contact_id]})
    end
  
    if Erp::Core.available?("periods")
      if options[:period].present?
        query = query.where('erp_consignments_consignments.sent_date >= ? AND erp_consignments_consignments.sent_date <= ?',
          Erp::Periods::Period.find(options[:period]).from_date.beginning_of_day,
          Erp::Periods::Period.find(options[:period]).to_date.end_of_day)
      end
    end
    
    query
  end
end