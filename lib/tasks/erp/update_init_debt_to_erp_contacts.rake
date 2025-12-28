# lib/tasks/erp_contacts_tasks.rake

namespace :erp do
  namespace :contacts do
    desc "Update initial debt for contacts from an Excel file. Only processes rows where the debt amount is a valid number. Usage: FILE_PATH='path/to/your/file.xlsx' bundle exec rake erp:contacts:update_initial_debt"
    task update_initial_debt: :environment do |t|
      # --- Cấu hình ---
      file_path = ENV['FILE_PATH']

      unless file_path.present? && File.exist?(file_path)
        puts "Lỗi: Vui lòng cung cấp đường dẫn file Excel hợp lệ."
        puts "Ví dụ: FILE_PATH='duong/dan/den/file.xlsx' bundle exec rake #{t.name}"
        next
      end

      # Ngày nợ đầu kỳ cố định
      INIT_DEBT_DATE = Date.new(2025, 6, 30).end_of_day - 2.hours

      # Vị trí các cột trong file Excel (bắt đầu từ 0)
      COLUMN_INDEX_NAME = 0
      COLUMN_INDEX_DEBT_AMOUNT = 1

      puts " Bắt đầu quá trình cập nhật công nợ đầu kỳ từ file: #{file_path} ".center(80, '-')

      # Mở file Excel
      xlsx = Roo::Spreadsheet.open(file_path)
      sheet = xlsx.sheet(0) # Lấy sheet đầu tiên

      # Biến đếm
      processed_count = 0
      updated_count = 0
      not_found_count = 0
      skipped_count = 0

      # Bắt đầu duyệt từ dòng thứ 2 (bỏ qua dòng tiêu đề)
      sheet.each_row_streaming(offset: 1).with_index(2) do |row, row_num|
        processed_count += 1

        # Lấy giá trị từ các ô, chuyển thành chuỗi và loại bỏ khoảng trắng thừa
        contact_name = row[COLUMN_INDEX_NAME]&.value.to_s.strip
        debt_amount_value = row[COLUMN_INDEX_DEBT_AMOUNT]&.value.to_s.strip

        # Bỏ qua nếu tên liên hệ trống
        next if contact_name.blank?

        # --- LOGIC KIỂM TRA MỚI ---
        # Chỉ xử lý nếu giá trị công nợ là một số.
        # Regex này sẽ kiểm tra chuỗi có phải là số nguyên hoặc số thập phân (âm hoặc dương) hay không.
        # Các trường hợp như '', '-', 'abc' sẽ không hợp lệ.
        unless debt_amount_value.match?(/\A-?\d+(\.\d+)?\z/)
          puts "[Dòng #{row_num}] ⏩ Bỏ qua do giá trị công nợ không phải là số ('#{debt_amount_value}') cho '#{contact_name}'"
          skipped_count += 1
          next
        end
        # -------------------------

        # Tìm liên hệ dựa trên tên
        contact = Erp::Contacts::Contact.find_by(name: contact_name)

        if contact
          # Nếu tìm thấy, cập nhật thông tin
          contact.init_debt_amount = debt_amount_value.to_f
          contact.init_debt_date = INIT_DEBT_DATE

          if contact.save
            puts "[Dòng #{row_num}] ✔️  Đã cập nhật cho '#{contact.name}' với số nợ: #{contact.init_debt_amount}"
            updated_count += 1
          else
            puts "[Dòng #{row_num}] ❌  Lỗi khi lưu cho '#{contact.name}': #{contact.errors.full_messages.join(', ')}"
          end
        else
          # Nếu không tìm thấy, thông báo
          puts "[Dòng #{row_num}] ⚠️  Không tìm thấy liên hệ với tên '#{contact_name}'"
          not_found_count += 1
        end
      end

      puts " Hoàn thành! ".center(80, '-')
      puts "Tổng số dòng đã đọc: #{processed_count}"
      puts "Số liên hệ đã cập nhật thành công: #{updated_count}"
      puts "Số dòng bị bỏ qua (công nợ không hợp lệ): #{skipped_count}"
      puts "Số liên hệ không tìm thấy: #{not_found_count}"
    end
  end
end