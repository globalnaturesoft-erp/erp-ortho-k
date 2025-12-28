# lib/tasks/update_lens_code.rake

namespace :erp do
  namespace :products do
    desc "Update the missing product code"
    task update_lens_code: :environment do |t|
      LENS_REGEX = /\A[A-Z]+\d{2}-\d+(\.\d+)?-[A-Z\s]+\z/i
      len_cung = Erp::Products::Category.where(name: 'Len cứng').first
      len_ids = len_cung.children.where(archived: false).ids.map(&:to_s)
      products = Erp::Products::Product.where(category_id: len_ids)
      size = products.size
      count = 0
      products.each do |p|
        p_name = p.name
        code = p.code
        if code.nil? and p_name.split('-').count == 3 and p_name[0..2].downcase != 'cus' and (p_name =~ /\A\d.+/).nil? and p_name=~LENS_REGEX
          lns = p_name.scan(/\d+|\D+/)
          code = lns[0] + lns[1]
          p.code = code
          p.save
        end
        count += 1

        puts "(#{count} of #{size}) - [#{p.id}] #{p.name} >> (done)"
      end
    end
  end
end