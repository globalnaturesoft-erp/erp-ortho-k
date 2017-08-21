module Erp
  module OrthoK
    module Backend
      class SettingController < Erp::Backend::BackendController
        def index
          setting_file = 'setting_ortho_k.conf'
          if params.to_unsafe_hash[:options].present?
            File.open(setting_file, 'w') {|f| f.write(YAML.dump(params.to_unsafe_hash[:options])) }
          end

          @options = {"purchase_conditions" => nil, "central_conditions" => nil}
          if File.file?(setting_file)
            @options = YAML.load(File.read(setting_file))
          end
        end
        def purchase_condition
          render partial: params[:partial], locals: {
            uid: helpers.unique_id()
          }
        end
        def central_condition
          render partial: params[:partial], locals: {
            uid: helpers.unique_id()
          }
        end
      end
    end
  end
end
