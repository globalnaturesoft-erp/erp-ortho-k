Erp::Core::Engine.routes.draw do
	root to: "backend/dashboard#index"
end

Erp::OrthoK::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "orthok/backend/products" do
      resources :products do
        collection do
          get 'matrix_report'
          post 'matrix_report_table'
          get 'tooltip_warehouse_info'
          get 'delivery_report'
          get 'delivery_report_by_cate_diameter'
          post 'delivery_report_table'
          get 'warehouses_report'
          post 'warehouses_report_table'
          get 'stock_importing'
          post 'stock_importing_table'
          get 'stock_transfering'
          post 'stock_transfering_table'
          get 'import_export_report'
          post 'import_export_report_table'
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

			resources :accountings do
				collection do
					get 'report_pay_receive'
					post 'report_pay_receive_table'
					get 'report_synthesis_pay_receive'
					post 'report_synthesis_pay_receive_table'
					get 'report_sales_results'
					post 'report_sales_results_table'
					get 'report_income_statement'
					post 'report_income_statement_table'
					get 'report_cash_flow'
					post 'report_cash_flow_table'
					get 'report_customer_liabilities'
					post 'report_customer_liabilities_table'
					get 'report_supplier_liabilities'
					post 'report_supplier_liabilities_table'
					get 'report_statistics_liabilities'
					post 'report_statistics_liabilities_table'
				end
			end

			resources :inventory do
				collection do
					get 'report_category_diameter'
					post 'report_category_diameter_table'

					get 'report_product'
					post 'report_product_table'

					get 'report_central_area'
					post 'report_central_area_table'

					get 'report_warehouse'
					post 'report_warehouse_table'

					get 'report_custom_area'
					post 'report_custom_area_table'

					get 'report_outside_product'
					post 'report_outside_product_table'
				end
			end

			get 'setting', :to => "setting#index"
			post 'setting', :to => "setting#index"
			get 'purchase_condition', :to => "setting#purchase_condition", :as => 'purchase_condition'
			get 'central_condition', :to => "setting#central_condition", :as => 'central_condition'

    end
	end

end
