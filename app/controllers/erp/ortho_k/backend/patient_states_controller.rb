module Erp
  module OrthoK
    module Backend
      class PatientStatesController < Erp::Backend::BackendController
        before_action :set_patient_state, only: [:show, :edit, :update, :destroy]
    
        # GET /patient_states
        def index
          #@patient_states = PatientState.all
        end
        
        def list
          @patient_states = PatientState.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end
    
        # GET /patient_states/1
        def show
        end
    
        # GET /patient_states/new
        def new
          @patient_state = PatientState.new
        end
    
        # GET /patient_states/1/edit
        def edit
        end
    
        # POST /patient_states
        def create
          @patient_state = PatientState.new(patient_state_params)
    
          if @patient_state.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @patient_state.name,
                value: @patient_state.id
              }
            else
              redirect_to erp_ortho_k.edit_backend_patient_state_path(@patient_state), notice: t('.success')
            end
          else
            render :new
          end
        end
    
        # PATCH/PUT /patient_states/1
        def update
          if @patient_state.update(patient_state_params)
            if request.xhr?
              render json: {
                status: 'success',
                text: @patient_state.name,
                value: @patient_state.id
              }
            else
              redirect_to erp_ortho_k.edit_backend_patient_state_path(@patient_state), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /patient_states/1
        def destroy
          @patient_state.destroy
          
          respond_to do |format|
            format.html { redirect_to erp_ortho_k.backend_patient_states_path, notice: t('.success') }
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
              render json: PatientState.dataselect(params[:keyword], params)
            }
          end
        end
    
        private
          # Use callbacks to share common setup or constraints between actions.
          def set_patient_state
            @patient_state = PatientState.find(params[:id])
          end
    
          # Only allow a trusted parameter "white list" through.
          def patient_state_params
            params.fetch(:patient_state, {}).permit(:name, :description)
          end
      end
    end
  end
end
