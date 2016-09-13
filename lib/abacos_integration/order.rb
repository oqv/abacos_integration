module AbacosIntegration
  class Order < Base
    attr_reader :order_payload

    def initialize(config, payload={})
      super config
      if payload.present?
        @order_payload = payload
        @order_payload = JSON.parse(@order_payload).symbolize_keys if @order_payload.is_a? String
        @order_payload = @order_payload[:order].deep_symbolize_keys if @order_payload.is_a? Hash
      end
    end

    def create
      #send_customer_info
      Abacos.add_orders [build_order.translated]
    end

    # NOTE Map Order statuses (codigo_status). e.g.
    #
    #   ENT => delivered ?
    #
    def fetch
      Abacos.orders_available_status.map do |order|
        {
          id: order[:numero_pedido],
          abacos: order
        }
      end
    end

    def confirm!(protocol=nil)
      protocol ||= order_payload[:abacos][:protocolo_status_pedido]
      Abacos.confirm_order_status_received protocol
    end

    def build_order
      order_payload[:line_items] = []
      order_payload[:payments] = []
      order_payload[:value_discounts] = 0

      # Value discounts
      if order_payload[:order_promotions].present?
        order_payload[:order_promotions].each do |promotion|
          order_payload[:value_discounts] += promotion[:value_discount].to_f
        end
      end
      
      # Products
      order_payload[:order_products].each do |product|
        # line = Abacos::Line.new product
        # line.price_ref ||= line.price
        # line.price_unit ||= line.price
        product[:price_unit] ||= product[:price]
        product[:price_ref] ||= product[:price]
        product[:price] = (product[:price].to_f - (product[:promo_total].to_f/product[:quantity]))

        unless product[:is_freebie]
          # we need the price without modifications to make the magic, so, we use "price_ref"
          price_in_order = product[:price_ref].to_f * product[:quantity].to_f
          percent_in_order = price_in_order * 100.0 / order_payload[:product_total].to_f

          product[:price] -= (order_payload[:value_discounts] * percent_in_order / 100.0) / product[:quantity].to_f
        end

        #if product[:price].to_f != product[:price_unit].to_f
        #  product[:personalizations] = []
        #  product[:personalizations] << { price_liquid: product[:price], sku: product[:sku] }
        #end
        order_payload[:line_items] << product
      end

      # Payments
      order_payload[:order_payments].each do |payment|
        # pay = Abacos::Payment.new payment
        payment[:exp_date] = Abacos::Helper.parse_timestamp(payment[:exp_date]) rescue nil
        payment[:credit_card_expire_date] = Abacos::Helper.parse_creditcard_time(payment[:credit_card_expire_date]) rescue nil
        order_payload[:payments] << payment
      end

      order = Abacos::Order.new order_payload
      #order.shipping = order_payload[:totals][:shipping]
      #order.total = order_payload[:totals][:item]
      order.product_total = order.product_total.to_f
      order.product_total -= order_payload[:promo_total].to_f
      # era pra ser o jeito certo, mas~
      # order.discount = order_payload[:value_discounts]

      created_at = Abacos::Helper.parse_timestamp order_payload[:created_at]
      order.created_at = created_at

      order.client_code ||= order.client_cpf

      # Integrate paid order directly
      # paid_status = order_payload[:order_statuses].find { |order_status| order_status[:status] == 'paid' }
      # order.paid_status = paid_status.present?
      # order.payment_date = paid_status.present? ? Abacos::Helper.parse_timestamp(paid_status[:created_at]) : nil

      # Defaults. These are preconfigured on Abacos
      order.commercialization_kind ||= '0'
      order.seller_id = '1'
      order.shipment_service_id ||= "83"
      #order.shipment_service ||= order.shipment_service_id
      order.paid_status ||= false
      order.nf_paulista ||= 'tbneSim'
      order.fake_invoice ||= false
      order.charges_total ||= 0
      order.shipment_total_pay ||= order.shipment_total

      # Address data
      order.contact = order_payload[:order_address][:contact]
      order.contact_phone = order_payload[:order_address][:phone]
      order.contact_email ||= order.client_email
      #order.contact_cpf = order_payload[:order_address][:contact_cpf]
      order.contact_type_abacos = order_payload[:order_address][:contact_type_abacos]
      order.address_client_cpf ||= order.client_cpf
      order.address_street = order_payload[:order_address][:street]
      order.address_number = order_payload[:order_address][:number]
      order.address_complement = order_payload[:order_address][:complement]
      order.address_neighborhood = order_payload[:order_address][:neighborhood]
      order.address_city = order_payload[:order_address][:city]
      order.address_state = order_payload[:order_address][:state]
      order.address_zip_code = order_payload[:order_address][:zip_code]
      order.address_type_abacos = order_payload[:order_address][:address_type_abacos]

      order.quote_id = order_payload[:quote_id]
      order.shipment_cost_price = order_payload[:shipment_cost_price]

      order
    end

    def send_customer_info
      customer = Abacos::Customer.new customer_payload
      Abacos.add_customers [customer.translated]
    end

    def customer_payload
      {
        'firstname' => order_payload[:billing_address][:firstname],
        'lastname' => order_payload[:billing_address][:lastname],
        'email' => order_payload[:email],
        'cpf_or_cnpj' => order_payload[:cpf_or_cnpj],
        'kind' => order_payload[:kind] || "tpeFisica",
        'gender' => order_payload[:gender] || "tseFeminino",
        'billing_address' => order_payload[:billing_address]
      }
    end
  end
end
