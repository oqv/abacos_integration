module AbacosIntegration
  class Price < Base
    attr_reader :price_payload

    def initialize(config = {}, payload = {})
      super config
    end

    # We're using `codigo_produto_abacos` as the ID key here to facilicate
    # moving this info to a storefront that requires IDs to be unique numbers
    # only
    #
    # abacos_id can be used by integrations what requires a reference value
    # with only numbers (id might contain other chars)
    def fetch
      Abacos.prices_available.map do |s|
        {
          id: s[:codigo_produto],
          code_abacos: s[:codigo_produto_pai],
          price: s[:preco_tabela],
          promotional_price: s[:preco_promocional],
          protocolo_preco: s[:protocolo_preco]
        }
      end
    end

    def confirm(protocol)
      Abacos.confirm_price_received protocol
    end
  end
end
