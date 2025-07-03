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
        output_file = input_file.sub(/\.xlsx$/, " (UPDATED state_#{} wh_#{wh_id}).xlsx")
        puts "Đang xử lý file: #{input_file}"

        # Mở file Excel
        xlsx = Roo::Excelx.new(input_file)
        Axlsx::Package.new do |p|
          p.workbook do |wb|
            # Duyệt qua từng sheet
            xlsx.sheets.each do |sheet_name|
              xlsx.default_sheet = sheet_name
              headers = xlsx.row(4) # Tiêu đề ở dòng 4
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

  desc "Nhập sản phẩm từ file Excel vào cơ sở dữ liệu"
  task :import, [:file_path] => :environment do |t, args|
    file_path = args[:file_path] || "Danh sach san pham_cap_nhat.xlsx"

    begin
      xlsx = Roo::Excelx.new(file_path)
      xlsx.sheets.each do |sheet_name|
        xlsx.default_sheet = sheet_name
        (5..xlsx.last_row).each do |i|
          row = xlsx.row(i)
          next if row[0].to_s.downcase.include?("tổng cộng") # Bỏ qua dòng tổng

          # Ánh xạ dữ liệu Excel sang thuộc tính sản phẩm
          product_attributes = {
            name: row[0],
            code: row[1],
            letter: row[2],
            number: row[3]&.to_i,
            diameter: row[4]&.to_f,
            type: row[5],
            power: row[6]&.to_f,
            k_power: row[7],
            k2_power: row[8],
            cost_price: row[9]&.to_f,
            selling_price: row[10]&.to_f,
            stock: row[11]&.to_i,
            note: row[12],
            is_outside: row[13] == "Có", # Chuyển "Có" thành true, "Không" thành false
            category: sheet_name
          }

          # Kiểm tra sản phẩm đã tồn tại
          existing_product = Product.find_by(name: product_attributes[:name])
          if existing_product
            puts "Bỏ qua sản phẩm trùng lặp: #{product_attributes[:name]} trong chuyên mục #{sheet_name}"
          else
            Product.create!(product_attributes)
            puts "Đã nhập sản phẩm: #{product_attributes[:name]} trong chuyên mục #{sheet_name}"
          end
        end
      end
      puts "Hoàn tất nhập sản phẩm"
    rescue StandardError => e
      puts "Lỗi khi nhập sản phẩm: #{e.message}"
    end
  end
end