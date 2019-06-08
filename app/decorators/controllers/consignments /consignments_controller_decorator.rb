Erp::Consignments::Backend::ConsignmentsController.class_eval do
  # POST /deliveries/1
  def import_file
    if params[:id].present?
      @consignment = Erp::Consignments::Consignment.find(params[:id])
      @consignment.assign_attributes(consignment_params)

      if params[:import_file].present?
        @consignment.import(params[:import_file], consignment_params)
      end

      render :edit
    else
      @consignment = Erp::Consignments::Consignment.new(consignment_params)

      if params[:import_file].present?
        @consignment.import(params[:import_file], consignment_params)
      end

      render :new
    end
  end
end