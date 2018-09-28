module Erp
  module OrthoK
    module Backend
      class PatientStatesController < Erp::Backend::BackendController
        before_action :set_patient_state, only: [:show, :edit, :update, :set_active, :set_deleted]
    
        # GET /patient_states
        def index
          authorize! :contacts_patient_states_index, nil
        end
        
        def list
          authorize! :contacts_patient_states_index, nil
          
          @patient_states = PatientState.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end
    
        # GET /patient_states/1
        def show
        end
    
        # GET /patient_states/new
        def new
          @patient_state = PatientState.new
          
          authorize! :create, @patient_state
        end
    
        # GET /patient_states/1/edit
        def edit
          authorize! :update, @patient_state
        end
    
        # POST /patient_states
        def create
          @patient_state = PatientState.new(patient_state_params)
          
          authorize! :create, @patient_state
    
          if @patient_state.save
            @patient_state.set_active
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
          authorize! :update, @patient_state
          
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
        #def destroy
        #  @patient_state.destroy
        #  
        #  respond_to do |format|
        #    format.html { redirect_to erp_ortho_k.backend_patient_states_path, notice: t('.success') }
        #    format.json {
        #      render json: {
        #        'message': t('.success'),
        #        'type': 'success'
        #      }
        #    }
        #  end
        #end
        
        def dataselect
          respond_to do |format|
            format.json {
              render json: PatientState.dataselect(params[:keyword], params)
            }
          end
        end
        
        # Active /patient_state/status?id=1
        def set_active
          authorize! :set_active, @patient_state
          
          @patient_state.set_active

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end
    
        # Delete /patient_state/status?id=1
        def set_deleted
          authorize! :set_deleted, @patient_state
          
          @patient_state.set_deleted

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
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
