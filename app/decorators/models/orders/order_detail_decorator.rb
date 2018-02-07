Erp::Orders::OrderDetail.class_eval do
  def display_eye_position
    if self.eye_position.present?
      if [Erp::Orders::Order::POSITION_LEFT,
          Erp::Orders::Order::POSITION_RIGHT,
          Erp::Orders::Order::POSITION_BOTH].include?(self.eye_position)
        return I18n.t(".#{eye_position}_eye")
      else
        return ''
      end
    else
      return ''
    end
  end
end