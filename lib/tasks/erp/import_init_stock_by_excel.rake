namespace :products do
  require 'roo'
  require 'set'

  desc "Tạo Delivery và DeliveryDetails từ file Excel"
  task :import_init_stock, [:file_path, :note] => :environment do |t, args|
    file_path = args[:file_path]
    note = args[:note] || ""
    unless file_path
      error_msg = "Không cung cấp đường dẫn file Excel"
      puts "Lỗi: #{error_msg}"
      File.open(Rails.root.join("log/import_errors_no_file.log"), "a") do |f|
        f.puts "[#{Time.now}] File: #{file_path || 'không xác định'}, Error: #{error_msg}"
      end
      next
    end

    # Tạo tên file log từ file_path
    file_name = File.basename(file_path, ".xlsx")
    log_file = Rails.root.join("log/import_errors_#{file_name}.log")

    begin
      Erp::Products::Product.connection
      xlsx = Roo::Excelx.new(file_path)

      user = Erp::User.first
      unless user
        error_msg = "Không tìm thấy người dùng nào trong hệ thống"
        puts "Lỗi: #{error_msg}"
        File.open(log_file, "a") do |f|
          f.puts "[#{Time.now}] File: #{file_path}, Error: #{error_msg}"
        end
        next
      end

      state = Erp::Products::State.first
      unless state
        error_msg = "Không tìm thấy trạng thái nào trong hệ thống"
        puts "Lỗi: #{error_msg}"
        File.open(log_file, "a") do |f|
          f.puts "[#{Time.now}] File: #{file_path}, Error: #{error_msg}"
        end
        next
      end

      init_datetime = '2025-06-30'.to_date.end_of_day - 2.hours
      processed_product_names = Set.new

      ActiveRecord::Base.transaction do
        xlsx.sheets.each do |sheet_name|
          xlsx.default_sheet = sheet_name

          headers = xlsx.row(1)
          name_col_index = headers.index("Tên sản phẩm")
          stock_col_index = headers.index("Tồn kho")
          warehouse_col_index = headers.index("Kho")

          unless name_col_index && stock_col_index
            error_msg = "Không tìm thấy cột 'Tên sản phẩm' hoặc 'Tồn kho' trong sheet #{sheet_name}"
            puts "Lỗi: #{error_msg}"
            File.open(log_file, "a") do |f|
              f.puts "[#{Time.now}] File: #{file_path}, Sheet: #{sheet_name}, Error: #{error_msg}"
            end
            next
          end

          delivery = Erp::Qdeliveries::Delivery.new(
            creator_id: user.id,
            date: init_datetime,
            delivery_type: "custom_import",
            note: "Nhập tồn đầu: #{sheet_name} - #{note}",
            status: "delivered",
            archived: false,
            employee_id: user.id,
            created_at: init_datetime,
            updated_at: init_datetime
          )

          (1..xlsx.last_row).each_with_index do |i,index|
            row = xlsx.row(i)
            next if row[name_col_index].to_s.downcase.include?("tổng cộng")

            ten_san_pham = row[name_col_index]&.to_s
            next unless ten_san_pham
            next if processed_product_names.include?(ten_san_pham)

            stock = row[stock_col_index]&.to_i || 0
            next if stock.zero? || stock.negative?

            product = Erp::Products::Product.find_by(name: ten_san_pham)
            unless product
              error_msg = "Không tìm thấy sản phẩm: #{ten_san_pham}"
              puts "Lỗi: #{error_msg}"
              File.open(log_file, "a") do |f|
                f.puts "[#{Time.now}] File: #{file_path}, Sheet: #{sheet_name}, Product: #{ten_san_pham}, Error: #{error_msg}"
              end
              next
            end

            warehouse_name = row[warehouse_col_index]&.to_s&.strip&.downcase
            wh_name = (warehouse_name == 'kho hàng y tế mỹ' || warehouse_name == 'ytm') ? 'hn' : warehouse_name
            warehouse = Erp::Warehouses::Warehouse.where("TRIM(LOWER(name)) = ?", wh_name).first
            unless warehouse
              error_msg = "Không tìm thấy kho: #{wh_name}"
              puts "Lỗi: #{error_msg}"
              File.open(log_file, "a") do |f|
                f.puts "[#{Time.now}] File: #{file_path}, Sheet: #{sheet_name}, Product: #{ten_san_pham}, Error: #{error_msg}"
              end
              next
            end

            delivery.delivery_details.build(
              product_id: product.id,
              quantity: stock,
              state_id: state.id,
              warehouse_id: warehouse.id,
              note: "Nhập từ file",
              created_at: init_datetime,
              updated_at: init_datetime
            )

            puts "Đang xử lý: #{product.name} (Delivery ID: #{delivery.id || 'chưa lưu'}, Stock: #{stock})"
            processed_product_names.add(ten_san_pham)
          end

          if delivery.delivery_details.empty?
            error_msg = "Không có số lượng tồn để nhập"
            puts "Mục #{sheet_name} không có số lượng tồn để nhập, bỏ qua"
            File.open(log_file, "a") do |f|
              f.puts "[#{Time.now}] File: #{file_path}, Sheet: #{sheet_name}, Error: #{error_msg}"
            end
            next
          end

          delivery.save!
          puts "Đã tạo phiếu nhập tồn đầu cho: #{sheet_name} (DeliveryID: #{delivery.id})"
        end
      end
      puts "FINISHED: #{file_path}"
    rescue StandardError => e
      error_msg = "Lỗi tổng quát: #{e.message}"
      puts error_msg
      File.open(log_file, "a") do |f|
        f.puts "[#{Time.now}] File: #{file_path}, Error: #{error_msg}"
      end
      raise
    end
  end
end