Erp::Consignments::Consignment.class_eval do
  # import file
  def import(file, consignment_params={})
    self.consignment_details = []
    
    spreadsheet = Roo::Spreadsheet.open(file.path)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]

      # Find product
      # p_name = "#{row["code"].to_s.strip}-#{row["diameter"].to_s.strip}-#{row["category"].to_s.strip}"
      p_name = row["name"]

      if p_name.split('-').count == 3 and p_name[0..2].downcase != 'cus' and (p_name =~ /\A\d.+/).nil?
        lns = p_name.scan(/\d+|\D+/)

        # number
        nn_v = lns[1]
        nn_v = nn_v.rjust(2, '0') if nn_v != '0' and nn_v != '00'

        p_name = lns[0] + nn_v + "-" + p_name.split('-')[1] + "-" + p_name.split('-')[2]
      end

      product = Erp::Products::Product.where('name = ?', p_name.strip).first
      product_id = product.present? ? product.id : nil

      if product.present?        
        # state       
        state = Erp::Products::State.where('LOWER(name) = ?', row["state"].strip.downcase).first
        
        if row["quantity"].to_i > 0
          self.consignment_details.build(
            id: nil,
            product_id: product_id,
            quantity: row["quantity"],
            serials: row["serials"],
            state_id: (state.present? ? state.id : nil),
          )
        end
      end
    end
  end
end