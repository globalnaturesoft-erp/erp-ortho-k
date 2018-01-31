Erp::Core::Engine.routes.draw do
	root to: "backend/dashboard#index"
end

Erp::Products::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "orthok/backend" do
      resources :products do
        collection do
          get 'split'
          post 'do_split'
          get 'ajax_split_quantity'
          get 'ajax_preview_split'

          get 'combine'
          post 'do_combine'
          get 'ajax_combine_quantity'
          get 'ajax_preview_combine'

          get 'ajax_deltak_calculating'

          get 'list_split'
          post 'list_split_list'
        end
      end
    end
	end
end

Erp::Payments::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "orthok/backend" do
      resources :payment_records do
        collection do
					get 'commission_with_for_order_xlsx'
					get 'commission_with_for_contact_xlsx'
					get 'employee_target_xlsx'
					get 'company_target_xlsx'
					get 'commission_xlsx'
        end
      end
    end
	end
end

Erp::Orders::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "orthok/backend" do
      resources :orders do
        collection do
					post 'import_file'
        end
      end
    end
	end
end

Erp::OrthoK::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
		namespace :backend, module: "backend", path: "orthok/backend/products" do
      resources :products do
        collection do
          get 'matrix_report'
          post 'matrix_report_table'
          get 'matrix_report_xlsx'
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

          get 'import'
          post 'import'

          get 'purchasing_export'
          post 'purchasing_export'
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

      resources :patient_states do
        collection do
					post 'list'
					get 'dataselect'
				end
			end

			resources :orders do
				collection do
					get 'patient_info'
					post 'change_checking_order'
				end
			end

			resources :accountings do
				collection do
					get 'report_pay_receive'
					post 'report_pay_receive_table'
					get 'report_pay_receive_xlsx'

					get 'report_synthesis_pay_receive'
					post 'report_synthesis_pay_receive_table'
					get 'report_synthesis_pay_receive_xlsx'

					get 'report_sales_results'
					post 'report_sales_results_table'
					get 'report_sales_results_xlsx'

					get 'report_income_statement'
					post 'report_income_statement_table'
					get 'report_income_statement_xlsx'

					get 'report_cash_flow'
					post 'report_cash_flow_table'
					get 'report_cash_flow_xlsx'

					get 'report_customer_liabilities'
					post 'report_customer_liabilities_table'
					get 'report_customer_liabilities_xlsx'

					get 'report_supplier_liabilities'
					post 'report_supplier_liabilities_table'
					get 'report_supplier_liabilities_xlsx'

					get 'report_statistics_liabilities'
					post 'report_statistics_liabilities_table'
					get 'report_statistics_liabilities_xlsx'

					get 'report_liabilities_arising'
					post 'report_liabilities_arising_table'
					get 'report_liabilities_arising_xlsx'
				end
			end

			resources :inventory do
				collection do
					get 'report_category_diameter'
					post 'report_category_diameter_table'
					get 'report_category_diameter_xlsx'

					get 'report_product'
					post 'report_product_table'
					get 'report_product_xlsx'

					get 'report_central_area'
					post 'report_central_area_table'
					get 'report_central_area_xlsx'

					get 'report_warehouse'
					post 'report_warehouse_table'
					get 'report_warehouse_xlsx'

					get 'report_custom_area'
					post 'report_custom_area_table'
					get 'report_custom_area_xlsx'

					get 'report_outside_product'
					post 'report_outside_product_table'
					get 'report_outside_product_xlsx'

					get 'report_product_warehouse'
					post 'report_product_warehouse_table'
					get 'report_product_warehouse_xlsx'

					get 'report_custom_area_v2'
					post 'report_custom_area_v2_table'
					get 'report_custom_area_v2_xlsx'

					get 'report_product_request'
          post 'report_product_request_table'
          get 'report_product_request_xlsx'

          get 'report_product_ordered'
          post 'report_product_ordered_table'
          get 'report_product_ordered_xlsx'
				end
			end

			resources :sales do
				collection do
					get 'report_sell_and_return'
					post 'report_sell_and_return_table'
					get 'report_sell_and_return_xlsx'

					get 'report_sales_details'
					post 'report_sales_details_table'
					get 'report_sales_details_xlsx'

					get 'report_product_sold'
					post 'report_product_sold_table'
					get 'report_product_sold_xlsx'

					get 'report_product_return'
					post 'report_product_return_table'
					get 'report_product_return_xlsx'

					get 'report_new_patient'
					post 'report_new_patient_table'
					get 'report_new_patient_xlsx'
				end
			end

			resources :notification do
				collection do
					get 'notification_badge'
				end
			end

			get 'setting', :to => "setting#index"
			post 'setting', :to => "setting#index"
			get 'purchase_condition', :to => "setting#purchase_condition", :as => 'purchase_condition'
			get 'central_condition', :to => "setting#central_condition", :as => 'central_condition'

    end
	end

end
