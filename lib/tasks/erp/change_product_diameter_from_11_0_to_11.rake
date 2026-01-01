namespace :erp do
  namespace :products do
    desc "Change product diameter from 11.0 to 11 and update cache"
    task change_product_diameter_from_11_0_to_11: :environment do |t|
      # Define log file
      log_file = File.join(Rails.root, 'log', "change_diameter-#{Time.current.strftime('%Y%m%d%H%M%S')}.log")
      logger = Logger.new(log_file)
      logger.info("--- START RUNNING THE TASK: #{Time.current} ---")

      id_11_0 = 225
      id_11 = 159

      # Get product IDs that have diameter 11.0
      product_ids_11_0 = Erp::Products::ProductsValue.where(properties_value_id: id_11_0).pluck(:product_id).uniq

      logger.info("Found #{product_ids_11_0.count} products with diameter 11.0")
      puts "Found #{product_ids_11_0.count} products with diameter 11.0"

      product_ids_11_0.each do |p_id|
        begin
          product = Erp::Products::Product.find_by(id: p_id)
          next unless product # Skip if product not found

          puts "[#{p_id}] #{product.name}: Processing"
          logger.info("===== Product ID #{p_id} (#{product.name}) =====>>>>>")

          # Check if the product already has diameter 11
          exists_11 = Erp::Products::ProductsValue.exists?(product_id: p_id, properties_value_id: id_11)

          if exists_11
            # If 11 already exists, delete the 11.0 record
            Erp::Products::ProductsValue.where(product_id: p_id, properties_value_id: id_11_0).delete_all
            logger.info("Product ID #{p_id}: Successfully deleted diameter 11.0")
          else
            # If 11 does not exist, update from 11.0 to 11
            Erp::Products::ProductsValue.where(product_id: p_id, properties_value_id: id_11_0).update_all(properties_value_id: id_11)
            logger.info("Product ID #{p_id}: Successfully changed from 11.0 to 11")
          end

          # Update cache_pro by touch (trigger update_cache callback)
          product.touch
          puts "Changed from 11.0 to 11 --> successfully"
          logger.info("Product ID #{p_id}: Cache refreshed (touch)")

        rescue StandardError => e
          logger.error("ERROR at Product ID #{p_id}: #{e.message}")
        end
      end

      logger.info("--- END OF TASK: #{Time.current} ---")
      puts "Completed! Please check the log file at: log/change_diameter-#{Time.current.strftime('%Y%m%d%H%M%S')}.log"
    end
  end
end