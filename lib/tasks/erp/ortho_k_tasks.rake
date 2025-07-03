# desc "Explaining what the task does"
# task :ortho_k do
#   # Task goes here
# end
namespace :products do
  require 'roo'
  require 'axlsx'

  desc "Cập nhật danh sách file Excel với cột 'Ngoài bảng' và số liệu 'Tồn kho' từ cơ sở dữ liệu"
  task :update_excel, [:input_dir, :wh_id, :state_id] => :environment do |t, args|
    input_dir = args[:input_dir] || "database/products"
    wh_id = args[:wh_id] || "1" # Mặc định wh_id: 1
    state_id = args[:state_id] || "1" # Mặc định state_id: 1
    # Lấy danh sách file .xlsx trong thư mục
    input_files = Dir.glob(File.join(input_dir, "*.xlsx")).reject { |f| f.include?("(UPDATED state_#{} wh_#{wh_id})") }

    if input_files.empty?
      puts "Không tìm thấy file Excel nào trong thư mục #{input_dir}"
      next
    end

    begin
      # Đảm bảo kết nối cơ sở dữ liệu
      Erp::Products::Product.connection

      warehouse_name = Erp::Warehouses::Warehouse.find_by(id: wh_id)&.name || ""

      input_files.each do |input_file|
        output_file = input_file.sub(/\.xlsx$/, " (UPDATED state_#{state_id} wh_#{wh_id}).xlsx")
        puts "Đang xử lý file: #{input_file}"

        # Mở file Excel
        xlsx = Roo::Excelx.new(input_file)
        Axlsx::Package.new do |p|
          p.workbook do |wb|
            # Duyệt qua từng sheet
            xlsx.sheets.each do |sheet_name|
              xlsx.default_sheet = sheet_name
              headers = xlsx.row(1) # Tiêu đề ở dòng 1
              headers << "Ngoài bảng" # Thêm cột mới
              headers << "Đơn vị" # Thêm cột mới
              headers << "Thương hiệu" # Thêm cột mới
              headers << "Kho" # Thêm cột mới

              # Tạo sheet mới trong file Excel đầu ra
              wb.add_worksheet(name: sheet_name) do |sheet|
                # Thêm tiêu đề
                sheet.add_row headers

                # Xử lý từng dòng sản phẩm (từ dòng 5)
                (5..xlsx.last_row).each do |i|
                  row = xlsx.row(i)
                  next if row[0].to_s.downcase.include?("tổng cộng") # Bỏ qua dòng tổng

                  ten_san_pham = row[0]
                  # Tìm sản phẩm trong DB
                  product = Erp::Products::Product.find_by(name: ten_san_pham)
                  # Cập nhật tồn kho: ưu tiên get_stock, nếu không có thì dùng stock, hoặc mặc định 0
                  ton_kho = product&.get_stock(state_ids: state_id, warehouse_ids: wh_id) || 0

                  row[11] = ton_kho # Cập nhật cột Tồn kho (index 11)

                  ngoai_bang = product&.is_outside ? "Có" : "Không"
                  don_vi = product&.unit_name || "Cái" # Mặc định là "Cái" nếu không có đơn vị

                  thuong_hieu = product&.brand_name || ""

                  # Thêm giá trị cột bổ sung
                  row << ngoai_bang
                  row << don_vi
                  row << thuong_hieu
                  row << warehouse_name

                  sheet.add_row row
                end
              end
            end
          end
          # Lưu file Excel mới
          p.serialize(output_file)
        end
        puts "Đã cập nhật file Excel: #{output_file}"
      end
    rescue StandardError => e
      puts "Lỗi khi cập nhật file Excel: #{e.message}"
    end
  end

  desc "Tạo Delivery và DeliveryDetails từ file Excel"
  task :import, [:file_path] => :environment do |t, args|
    file_path = args[:file_path] || "database/products/Danh_sach_san_pham_cap_nhat.xlsx"

    begin
      Erp::Products::Product.connection
      xlsx = Roo::Excelx.new(file_path)

      user = Erp::User.first
      state = Erp::Products::State.first  # Mới

      # Theo dõi tên sản phẩm trên toàn bộ file để tránh trùng lặp
      processed_product_names = Set.new

      ActiveRecord::Base.transaction do
        xlsx.sheets.each do |sheet_name|
          xlsx.default_sheet = sheet_name

          # Lấy tiêu đề từ dòng đầu tiên
          headers = xlsx.row(1)
          # Tìm chỉ số cột dựa trên tên
          name_col_index = headers.index("Tên sản phẩm")
          stock_col_index = headers.index("Tồn kho")
          warehouse_col_index = headers.index("Kho")

          unless name_col_index && stock_col_index
            puts "Lỗi: Không tìm thấy cột 'Tên sản phẩm' hoặc 'Tồn kho' trong sheet #{sheet_name}"
            next
          end

          # Tạo Delivery cho category (sheet)
          delivery = Erp::Qdeliveries::Delivery.new(
            creator_id: user.id,
            date: '2025-06-30'.to_date,
            delivery_type: "custom_import",
            note: "NHẬP TỒN ĐẦU: #{sheet_name}",
            status: "delivered",
            archived: false,
            employee_id: user.id
          )

          (5..xlsx.last_row).each do |i|
            row = xlsx.row(i)
            next if row[name_col_index].to_s.downcase.include?("tổng cộng")

            ten_san_pham = row[name_col_index]&.to_s
            next unless ten_san_pham
            next if processed_product_names.include?(ten_san_pham)

            # Bỏ qua nếu tồn kho bằng 0
            stock = row[stock_col_index]&.to_i || 0
            next if stock.zero?

            # Tìm sản phẩm trong DB
            product = Erp::Products::Product.find_by(name: ten_san_pham)
            unless product
              puts "Không tìm thấy sản phẩm: #{ten_san_pham}, bỏ qua"
              next
            end

            warehouse_name = row[warehouse_col_index]&.to_s&.strip&.downcase
            wh_name = (warehouse_name == 'kho hàng y tế mỹ' || warehouse_name == 'ytm') ? 'hn' : warehouse_name
            warehouse = Erp::Warehouses::Warehouse.where("TRIM(LOWER(name)) = ?", wh_name).first
            unless warehouse
              puts "Không tìm thấy kho: #{wh_name}, bỏ qua"
              next
            end

            # Xây dựng DeliveryDetails trong bộ nhớ
            delivery.delivery_details.build(
              product_id: product.id,
              quantity: stock,
              state_id: state.id,
              warehouse_id: warehouse.id
            )

            puts "Đang xử lý: #{product.name} (Delivery ID: #{delivery.id || 'chưa lưu'}, Stock: #{stock})"

            # Thêm tên sản phẩm vào danh sách đã xử lý
            processed_product_names.add(ten_san_pham)
          end

          # Lưu Delivery và các DeliveryDetails
          if delivery.delivery_details.empty?
            puts "Mục #{sheet_name} không có số lượng tồn để nhập, bỏ qua"
            next
          end

          delivery.save!
          puts "Đã tạo phiếu nhập tồn đầu cho: #{sheet_name} (DeliveryID: #{delivery.id})"
        end
      end
      puts "FINISHED: #{file_path}"
    rescue StandardError => e
      puts "ERROR: #{e.message}"
      raise # Đảm bảo rollback transaction nếu có lỗi
    end
  end
end