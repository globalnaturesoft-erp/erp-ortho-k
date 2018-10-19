Erp::User.class_eval do
  # class const
  SUPER_ADMIN_ID = 1
  
  # Get super admin
  def self.get_super_admin
    #@todo: hard code
    return Erp::User.find(Erp::User::SUPER_ADMIN_ID)
  end
end