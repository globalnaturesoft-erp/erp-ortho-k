Erp::Products::Backend::ProductsController.class_eval do
  def split
    @product = params[:id].present? ? Erp::Products::Product.find(params[:id]) : nil
    @warehouse = Erp::Warehouses::Warehouse.first
    @state = Erp::Products::State.get_new_state
  end

  def do_split
    @product = Erp::Products::Product.find(params[:product_id])
    @warehouse = Erp::Warehouses::Warehouse.find(params[:warehouse_id])
    @state = Erp::Products::State.find(params[:state_id])
    @quantity = params[:quantity].to_i
    #if (@product.present? and @warehouse.present? and @state.present?)
      @product.split_parts(
        @quantity,
        { warehouse: @warehouse,
          state: @state,
          user: current_user
        }
      )

      respond_to do |format|
        format.html { redirect_to erp_products.backend_products_path, notice: t('.success') }
        format.json {
          render json: {
            'message': t('.success'),
            'type': 'success'
          }
        }
      end
    #end
  end

  def combine
    @product = params[:id].present? ? Erp::Products::Product.find(params[:id]) : nil
    @warehouse = Erp::Warehouses::Warehouse.first
    @state = Erp::Products::State.get_new_state
  end

  def do_combine
    @product = Erp::Products::Product.find(params[:product_id])
    @warehouse = Erp::Warehouses::Warehouse.find(params[:warehouse_id])
    @state = Erp::Products::State.find(params[:state_id])
    @quantity = params[:quantity].to_i

    @product.combine_parts(
      @quantity,
      { warehouse: @warehouse,
        state: @state,
        user: current_user
      }
    )

    respond_to do |format|
      format.html { redirect_to erp_products.backend_products_path, notice: t('.success') }
      format.json {
        render json: {
          'message': t('.success'),
          'type': 'success'
        }
      }
    end
  end

  def ajax_preview_split
    @product = Erp::Products::Product.where(id: params[:form_data][:product_id]).first
    @warehouse = Erp::Warehouses::Warehouse.where(id: params[:form_data][:warehouse_id]).first
    @state = Erp::Products::State.where(id: params[:form_data][:state_id]).first
    @quantity = params[:datas][0].to_i

    render layout: false
  end

  def ajax_preview_combine
    @product = Erp::Products::Product.where(id: params[:form_data][:product_id]).first
    @warehouse = Erp::Warehouses::Warehouse.where(id: params[:form_data][:warehouse_id]).first
    @state = Erp::Products::State.where(id: params[:form_data][:state_id]).first
    @quantity = params[:datas][0].to_i

    render layout: false
  end

  def ajax_split_quantity
    @product = Erp::Products::Product.where(id: params[:form_data][:product_id]).first
    @warehouse = Erp::Warehouses::Warehouse.where(id: params[:form_data][:warehouse_id]).first
    @state = Erp::Products::State.where(id: params[:form_data][:state_id]).first
    @max_quantity = @product.get_stock(warehouse: @warehouse, state: @state) if @product.present?

    render layout: false
  end

  def ajax_combine_quantity
    @product = Erp::Products::Product.where(id: params[:form_data][:product_id]).first
    @warehouse = Erp::Warehouses::Warehouse.where(id: params[:form_data][:warehouse_id]).first
    @state = Erp::Products::State.where(id: params[:form_data][:state_id]).first
    @max_quantity = @product.get_combine_max_quantity(warehouse: @warehouse, state: @state) if @product.present?

    render layout: false
  end

  def ajax_deltak_calculating
    @k = Erp::Products::PropertiesValue.where(id: params[:form_data][:degree_ks]).first
    @k2 = Erp::Products::PropertiesValue.where(id: params[:form_data][:degree_k2s]).first

    if @k.present? and @k2.present?
      @k = @k.value.split('/')
      @k2 = @k2.value.split('/')

      @deltak = [@k2[0].to_f - @k[0].to_f,@k2[1].to_f - @k[1].to_f]
      @avg = [(@k2[0].to_f + @k[0].to_f)/2,(@k2[1].to_f + @k[1].to_f)/2]
    end
  end

  def list_split

  end

  def list_split_list
    @products = Erp::Products::Product.search(params).paginate(:page => params[:page], :per_page => 20)

    render layout: nil
  end
end
