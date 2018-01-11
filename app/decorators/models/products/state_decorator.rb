Erp::Products::State.class_eval do
  def self.get_new_state
    self.first
  end
end