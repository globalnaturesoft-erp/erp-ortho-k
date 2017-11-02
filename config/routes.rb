Erp::OrthoK::Engine.routes.draw do
	root to: "frontend/home#index"

  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "orthok/backend/products" do
      resources :products do
        collection do
          get 'matrix_report'
          post 'matrix_report_table'
          get 'tooltip_warehouse_info'
          get 'delivery_report'
          post 'delivery_report_table'
          get 'warehouses_report'
          post 'warehouses_report_table'
          get 'stock_importing'
          post 'stock_importing_table'
          get 'stock_transfering'
          post 'stock_transfering_table'
          get 'import_report'
          post 'import_report_table'
          get 'export_report'
          post 'export_report_table'
        end
      end
      resources :central_areas do
        collection do
					post 'list'
					get 'dataselect'
					get 'area_dataselect'
				end
			end
      resources :property_values do
        collection do
					post 'list'
					get 'dataselect'
				end
			end
      resources :orders do
        collection do
					get 'patient_info'
				end
			end

      get 'setting', :to => "setting#index"
      post 'setting', :to => "setting#index"
      get 'purchase_condition', :to => "setting#purchase_condition", :as => 'purchase_condition'
      get 'central_condition', :to => "setting#central_condition", :as => 'central_condition'
    end
	end
end
