Erp::OrthoK::Engine.routes.draw do
	root to: "frontend/home#index"

  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "orthok/backend/products" do
      resources :products do
        collection do
          get 'matrix_report'
          post 'matrix_report_table'
          get 'delivery_report'
          post 'delivery_report_table'
          get 'warehouses_report'
          post 'warehouses_report_table'
          get 'stock_importing'
          post 'stock_importing_table'
          get 'stock_transfering'
          post 'stock_transfering_table'
        end
      end
      resources :central_areas do
        collection do
					post 'list'
					get 'dataselect'
				end
			end
      resources :property_values do
        collection do
					post 'list'
					get 'dataselect'
				end
			end
    end
	end
end
