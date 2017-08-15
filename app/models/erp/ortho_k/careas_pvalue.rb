module Erp::OrthoK
  class CareasPvalue < ApplicationRecord
    belongs_to :central_area
    belongs_to :property_value
  end
end