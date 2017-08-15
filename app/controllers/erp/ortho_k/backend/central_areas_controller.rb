module Erp
  module OrthoK
    module Backend
      class CentralAreasController < Erp::Backend::BackendController
        before_action :set_central_area, only: [:show, :edit, :update, :destroy]
    
        # GET /central_areas
        def index
        end
        
        def list
          @central_areas = CentralArea.search(params).paginate(:page => params[:page], :per_page => 10)
          
          render layout: nil
        end
        
        # GET /central_areas/1
        def show
        end
    
        # GET /central_areas/new
        def new
          @central_area = CentralArea.new
        end
    
        # GET /central_areas/1/edit
        def edit
        end
    
        # POST /central_areas
        def create
          @central_area = CentralArea.new(central_area_params)
          
          if @central_area.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @central_area.name,
                value: @central_area.id
              }              
            else
              redirect_to erp_ortho_k.edit_backend_central_area_path(@central_area), notice: t('.success')
            end            
          else
            render :new
          end
        end
    
        # PATCH/PUT /central_areas/1
        def update
          if @central_area.update(central_area_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @central_area.name,
                value: @central_area.id
              }              
            else
              redirect_to erp_ortho_k.edit_backend_central_area_path(@central_area), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /central_areas/1
        def destroy
          @central_area.destroy
          
          respond_to do |format|
            format.html { redirect_to erp_ortho_k.backend_central_areas_path, notice: t('.success') }
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
              render json: CentralArea.dataselect(params[:keyword], params)
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_central_area
            @central_area = CentralArea.find(params[:id])
          end
    
          # Only allow a trusted parameter "white list" through.
          def central_area_params
            params.fetch(:central_area, {}).permit(:name, property_value_ids: [])
          end
      end
    end
  end
end
