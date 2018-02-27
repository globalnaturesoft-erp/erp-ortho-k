module Erp
  module OrthoK
    module ApplicationHelper
      def axlsx_get_letter_by_index(num)
        index = num%26
        last = ('A'.codepoints.first+ index).chr
        first = (num/26).to_i == 0 ? '' : ('A'.codepoints.first + (num/26).to_i-1).chr
        "#{first}#{last}"
      end
    end
  end
end
