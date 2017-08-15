module Erp
  module OrthoK
    module Backend
      class PropertyValuesController < Erp::Backend::BackendController
        before_action :set_property_value, only: [:show, :edit, :update, :destroy]
    
        # GET /property_values
        def index
        end
        
        # GET /tags/1
        def list
          @property_values = PropertyValue.search(params).paginate(:page => params[:page], :per_page => 3)
          
          render layout: nil
        end
    
        # GET /property_values/1
        def show
        end
    
        # GET /property_values/new
        def new
          @property_value = PropertyValue.new
        end
    
        # GET /property_values/1/edit
        def edit
        end
    
        # POST /property_values
        def create
          @property_value = PropertyValue.new(property_value_params)
    
          if @property_value.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @property_value.value,
                value: @property_value.id
              }              
            else
              redirect_to erp_ortho_k.edit_backend_property_value_path(@property_value), notice: t('.success')
            end
          else
            render :new
          end
        end
    
        # PATCH/PUT /property_values/1
        def update
          if @property_value.update(property_value_params)
            redirect_to erp_ortho_k.edit_backend_property_value_path(@property_value), notice: t('.success')
          else
            render :edit
          end
        end
    
        # DELETE /property_values/1
        def destroy
          @property_value.destroy
          respond_to do |format|
            format.html { redirect_to erp_ortho_k.backend_property_values_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
          end
        end
        
        def dataselect
          respond_to do |format|
            format.json {
              render json: PropertyValue.dataselect(params[:keyword], params)
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_property_value
            @property_value = PropertyValue.find(params[:id])
          end
    
          # Only allow a trusted parameter "white list" through.
          def property_value_params
            params.fetch(:property_value, {}).permit(:value, property_value_ids: [])
          end
      end
    end
  end
end
