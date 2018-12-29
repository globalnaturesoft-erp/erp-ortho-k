Erp::GiftGivens::GivenDetail.class_eval do
  # get all active given details
  def self.get_gift_given_delivered_given_details(options={})
    query = Erp::GiftGivens::GivenDetail.joins(:given)
      .where(erp_gift_givens_givens: {status: Erp::GiftGivens::Given::STATUS_DELIVERED})
  
    if options[:from_date].present?
      query = query.where('erp_gift_givens_givens.given_date >= ?', options[:from_date].to_date.beginning_of_day)
    end
  
    if options[:to_date].present?
      query = query.where('erp_gift_givens_givens.given_date <= ?', options[:to_date].to_date.end_of_day)
    end
  
    if options[:contact_id].present?
      query = query.where(erp_gift_givens_givens: {contact_id: options[:contact_id]})
    end
  
    if Erp::Core.available?("periods")
      if options[:period].present?
        query = query.where('erp_gift_givens_givens.given_date >= ? AND erp_gift_givens_givens.given_date <= ?',
          Erp::Periods::Period.find(options[:period]).from_date.beginning_of_day,
          Erp::Periods::Period.find(options[:period]).to_date.end_of_day)
      end
    end
    
    query
  end
end