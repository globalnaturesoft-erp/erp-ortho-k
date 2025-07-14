namespace :inventories do
  require 'roo'
  require 'axlsx'

  desc "Cập nhật danh sách file Excel với cột 'Ngoài bảng' và số liệu 'Tồn kho' từ cơ sở dữ liệu"
  task :update_excel, [:input_dir, :warehouse_id, :state_id] => :environment do |t, args|
    input_dir = args[:input_dir] || "database/inventory"
    warehouse_id = args[:warehouse_id] || "1"
    state_id = args[:state_id] || "1"
    warehouse_name = Erp::Warehouses::Warehouse.find_by(id: warehouse_id)&.name || "Unknown"

    input_files = Dir.glob(File.join(input_dir, "*.xlsx")).reject { |f| f.include?("(#{warehouse_name})") }

    if input_files.empty?
      puts "Không tìm thấy file Excel nào trong thư mục #{input_dir}"
      next
    end

    begin
      Erp::Products::Product.connection

      input_files.each do |input_file|
        output_file = input_file.sub(/\.xlsx$/, " (#{warehouse_name}).xlsx")
        puts "Đang xử lý file: #{input_file}"

        xlsx = Roo::Excelx.new(input_file)
        Axlsx::Package.new do |p|
          p.workbook do |wb|
            # Định nghĩa style cơ bản để giống file đầu vào
            styles = p.workbook.styles
            default_style = styles.add_style(
              font_name: "Arial",
              sz: 12,
              alignment: { horizontal: :left, vertical: :center },
              border: { style: :thin, color: "000000" }
            )
            header_style = styles.add_style(
              font_name: "Arial",
              sz: 12,
              b: true,
              alignment: { horizontal: :center, vertical: :center },
              border: { style: :thin, color: "000000" }
            )

            xlsx.sheets.each do |sheet_name|
              xlsx.default_sheet = sheet_name

              # Lấy tiêu đề từ dòng 4
              headers = xlsx.row(4)
              name_col_index = headers.index("Tên sản phẩm")
              stock_col_index = headers.index("Tồn kho")

              unless name_col_index && stock_col_index
                puts "Lỗi: Không tìm thấy cột 'Tên sản phẩm' hoặc 'Tồn kho' trong sheet #{sheet_name}"
                next
              end

              # Kiểm tra và thêm các cột mới nếu chưa tồn tại
              ngoai_bang_col_index = headers.index("Ngoài bảng") || headers.length
              headers[ngoai_bang_col_index] = "Ngoài bảng" unless headers[ngoai_bang_col_index]
              don_vi_col_index = headers.index("Đơn vị") || headers.length
              headers[don_vi_col_index] = "Đơn vị" unless headers[don_vi_col_index]
              thuong_hieu_col_index = headers.index("Thương hiệu") || headers.length
              headers[thuong_hieu_col_index] = "Thương hiệu" unless headers[thuong_hieu_col_index]
              kho_col_index = headers.index("Kho") || headers.length
              headers[kho_col_index] = "Kho" unless headers[kho_col_index]

              # Tìm dòng "Tổng cộng"
              last_total_row_index = nil
              (5..xlsx.last_row).reverse_each do |i|
                row = xlsx.row(i)
                if row[name_col_index].to_s.downcase.include?("tổng cộng")
                  last_total_row_index = i
                  break
                end
              end

              wb.add_worksheet(name: sheet_name) do |sheet|
                sheet.add_row headers, style: header_style

                (5..xlsx.last_row).each do |i|
                  next if i == last_total_row_index

                  row = xlsx.row(i)
                  ten_san_pham = row[name_col_index]&.to_s
                  next unless ten_san_pham

                  product = Erp::Products::Product.find_by(name: ten_san_pham)
                  ton_kho =
                    product&.get_stock(
                      state_ids: state_id,
                      warehouse_ids: warehouse_id
                    ) || 0

                  # Cập nhật cột Tồn kho
                  row[stock_col_index] = ton_kho

                  ngoai_bang = product&.is_outside ? "Có" : "Không"
                  don_vi = product&.unit_name || "Cái"
                  thuong_hieu = product&.brand_name || ""

                  # Cập nhật hoặc thêm giá trị cho các cột
                  row[ngoai_bang_col_index] = ngoai_bang
                  row[don_vi_col_index] = don_vi
                  row[thuong_hieu_col_index] = thuong_hieu
                  row[kho_col_index] = warehouse_name

                  sheet.add_row row, style: default_style
                end
              end
            end
          end
          p.serialize(output_file)
        end
        puts "Đã cập nhật file Excel: #{output_file}"
      end
    rescue StandardError => e
      puts "Lỗi khi cập nhật file Excel: #{e.message}"
    end
  end
end