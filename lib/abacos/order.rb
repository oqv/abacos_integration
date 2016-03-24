class Abacos
  # Abacos > InserirPedido > DadosPedidos
  #
  #   {
  #     "NumeroDoPedido" => "R34545465465463",
  #     "EMail" => "3JJiiLSOIJYAzifBXQbhY7T8aMPSc0G3ZXbXVUJUJt/HATZDaaHLXpTuWeBKxjjT",
  #     "CPFouCNPJ" => "GRoxtlUMehBt7Y39nFhGXw==",
  #     "ValorPedido" => "100",
  #     "DataVenda" => "02102014 00:12:00.000",
  #     "RepresentanteVendas" => 1,
  #     "Transportadora" => "Transp [Direct]",
  #     "ServicoEntrega" => "Transp [Direct]",
  #     "Itens" => [
  #       {
  #         "DadosPedidosItem" => {
  #           "CodigoProduto" => "3104376",
  #           "QuantidadeProduto" => 1,
  #           "PrecoUnitario" => 100
  #         }
  #       }
  #     ],
  #     "FormasDePagamento" => [
  #       {
  #         "DadosPedidosFormaPgto" => {
  #           "FormaPagamentoCodigo" => "25",
  #           "CartaoQtdeParcelas" => 1,
  #           "Valor" => 100
  #         }
  #       }
  #     ]
  #   }
  #
  # CPFouCNPJ can only have numbers
  #
  # See pre configured payment methods in Abacos to grab a valid ID for FormaPagamentoCodigo
  # 
  class Order
    attr_reader :attributes

    @@mappings = {
      # Dados do cliente
      "client_email" => "Email",
      "client_cpf" => "CPFouCNPJ",
      "client_rg" => "DestDocumento",
      "client_code" => "CodigoCliente",
      "order_number" => "NumeroDoPedido",
      # Dados do Pedido
      "product_total" => "ValorPedido",
      "shipment_total" => "ValorFrete",
      "shipment_total_pay" => "ValorFretePagar",
      "charges_total" => "ValorEncargos",
      "discount" => "ValorDesconto",
      "gift_package_total" => "ValorEmbalagemPresente",
      "created_at" => "DataVenda",
      "shipment_service_id" => "Transportadora",
      "shipment_service" => "ServicoEntrega",
      "fake_invoice" => "EmitirNotaSimbolica",
      "promo_total_coupon" => "ValorCupomDesconto",
      # Dados de Entrega
      "client_name" => "DestNome",
      "contact_email" => "DestEmail",
      "contact_phone" => "DestTelefone",
      "address_client_cpf" => "DestCPF",
      "contact_type_abacos" => "DestTipoPessoa", # [tpeIndefinido, tpeFisica, tpeJuridica]
      "address_street" => "DestLogradouro",
      "address_number" => "DestNumeroLogradouro",
      "address_complement" => "DestComplementoEndereco",
      "address_neighborhood" => "DestBairro",
      "address_city" => "DestMunicipio",
      "address_state" => "DestEstado",
      "address_zip_code" => "DestCep",
      "address_type_abacos" => "DestTipoLocalEntrega", # [tleeDesconhecido, tleeResidencial, tleeComercial]
      "paid_status" => "PedidoJaPago",
      "nf_paulista" => "OptouNFPaulista",
      "gift_card_total" => "ValorTotalCartaoPresente",
      "gift_card_freebie" => "CartaoPresenteBrinde",
      "delivery_time" => "PrazoEntregaPosPagamento",
      "commercialization_kind" => "ComercializacaoOutrasSaidas",
      "seller_id" => "RepresentanteVendas"
    }

    @@obj_mappings = {
      "line_items" => "Abacos::Line Itens",
      "payments" => "Abacos::Payment FormasDePagamento"
    }

    # NOTE Some setter methods might require custom logic
    #
    # e.g. placed_on date needs to follow the format 
    #
    #   "DataVenda" => "ddmmyyyy 00:12:00.000",

    attr_reader *@@mappings.keys
    attr_reader *@@obj_mappings.keys
    attr_accessor :quote_id
    attr_accessor :shipment_cost_price

    def initialize(attributes = {})
      @attributes = attributes

      @translated = {}

      # Quote ID from Intelipost and delivery cost prince
      if attributes[:quote_id].present? && attributes[:shipment_cost_price].present?
        @translated['Anotacao3'] = "#{attributes[:quote_id]}_#{attributes[:shipment_cost_price]}"
      end

      @@mappings.each do |k, v|
        
        if attributes[k.to_sym]
          instance_variable_set("@#{k}", @translated[v] = attributes[k.to_sym])
        end

        self.class.send(:define_method, "#{k}=") do |value|
          instance_variable_set("@#{k}",  @translated[v] = value)
        end
      end

      # If order was paid with credits alone
      if attributes[:payments].size == 1 && attributes[:payments].first[:kind] == 'credit'
        @translated.delete('PrazoEntregaPosPagamento')

        @translated['DataPrazoEntregaInicial'] = Abacos::Helper.parse_timestamp((attributes[:delivery_time].to_i).business_days.after(attributes[:created_at].to_datetime).to_s) 
      end

      @@obj_mappings.each do |k, v|

        klass, translation = v.split

        instance_variable_set("@#{k}", [])

        (attributes[k.to_sym] || []).each do |line|
          horse_key = 'DadosPedidosItem' if klass.eql?('Abacos::Line')
          horse_key = 'DadosPedidosFormaPgto' if klass.eql?('Abacos::Payment')

          instance = klass.constantize.new line
          @translated[translation] ||= {}
          @translated[translation][horse_key] ||= []

          instance_variable_get("@#{k}").push instance
          @translated[translation][horse_key].push instance.translated

          # DadosPedidosFormaPgto, #DadosPedidosItem

        end
      end
    end

    def translated
      { "DadosPedidos" => @translated }
    end
  end
end
