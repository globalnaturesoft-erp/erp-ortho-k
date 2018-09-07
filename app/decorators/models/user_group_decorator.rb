Erp::UserGroup.class_eval do

  # Permission array
  def self.permissions_array
    arr = {
      
      # PHONG BAN HANG
      sales: {
        # sales engine
        sales: {
          orders: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
                {value: 'in_day', text: 'Trong ngày'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
        # gift givens engine
        gift_givens: {
          gift_givens: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          }
        },
        
        #consignments engine
        consignments: {
          consignments: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          cs_returns: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
        
        # prices engine
        prices: {
          customer_prices: {
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update_general: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          }
        },
      },
      
      # PHONG MUA HANG
      purchase: {
        #purchase engine
        purchase: {
          orders: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
                {value: 'in_day', text: 'Trong ngày'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
        prices: {
          supplier_prices: {
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update_general: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          }
        },
        products: {
          stock_import: {
            view: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          areas: {
            side: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            central: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          }
        },
      },
      
      # PHONG KHO (Inventory)
      inventory: {
        order_stock_checks: {
          schecks: {
            check: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            approve_order: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          }
        },
        qdeliveries: {
          deliveries: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            sales_orders: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            purchase_orders: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
                {value: 'in_day', text: 'Trong ngày'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          }
        },
        stock_transfers: {
          transfers: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            check_transfer: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          }
        },
        products: {
          warehouse_checks_with_state: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            approve: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
                {value: 'in_day', text: 'Trong ngày'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          warehouse_checks_with_stock: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            approve: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
                {value: 'in_day', text: 'Trong ngày'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          warehouse_checks_with_damage: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            approve: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
                {value: 'in_day', text: 'Trong ngày'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          products: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          warehouses: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          states: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          categories: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          properties: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          manufacturers: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
      },
      
      # PHONG KE TOAN
      accounting: {
        payments: {
          payment_records: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          accounts: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          payment_types: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            delete: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
        chase: {
          chase: {
            sales: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            sales_return: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            purchase: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            purchase_return: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          liabilities_tracking: {
            retail: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            customer: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            supplier: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          commision: {
            customer_commission: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            commission: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            target_commission: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
      },
      
      # QUAN LY LIEN HE
      contacts: {
        contacts: {
          contacts: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
        patient_states: {
          patient_states: {
            index: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
      },
      
      # NGHIEP VU BAO CAO/THONG KE
      report: {
        report: {
          inventory: {
            matrix: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            delivery: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            import_export_detail: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            category_diameter: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            code_diameter: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            product: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            custom_product: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            product_warehouse: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            central_area: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            custom_area: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            outside_product: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            warehouse: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            product_request: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            product_ordered: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          sales: {
            sales_and_returns: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            sales_details: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            product_sold: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            product_return_by_state: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            product_return_by_patient_state: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            new_patient: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            new_patient_v2: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          accounting: {
            pay_receive: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            synthesis_pay_receive: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            sales_results: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            sales_summary: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            income_statement: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            cash_flow: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            customer_liabilities: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            supplier_liabilities: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            liabilities_arising: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            statistics_liabilities: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
      },
      
      # CAU HINH/CAI DAT DU LIEU
      options: {
        users: {
          users: {
            index: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          user_groups: {
            index: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
        targets: {
          targets: {
            index: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'yes',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
          company_targets: {
            index: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
        periods: {
          periods: {
            index: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            create: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            update: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
      },
      
      # CAU HINH HE THONG / BACKUP / RESTORE
      system: {
        system: {
          system: {
            settings: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            backup: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
            restore: {
              value: 'no',
              options: [
                {value: 'yes', text: 'Có'},
                {value: 'no', text: 'Không'},
              ],
            },
          },
        },
      },
    }

    arr
  end
  
end
