class Abacos
  # Abacos > InserirPedido > DadosPedidos > FormasDePagamento
  #
  #   {
  #     "DadosPedidosFormaPgto" => {
  #       "FormaPagamentoCodigo" => "25",
  #       "CartaoQtdeParcelas" => 1,
  #       "Valor" => 100
  #     }
  #   }
  #
  class Payment
    attr_reader :attributes

    @@mappings = {
      "payment_abacos_method" => "FormaPagamentoCodigo",
      "total" => "Valor",
      "credit_card_number" => "CartaoNumero",
      "credit_card_code" => "CartaoCodigoSeguranca",
      "credit_card_expire_date" => "CartaoValidade",
      "credit_card_name" => "CartaoNomeImpresso",
      "credit_card_cpf" => "CartaoCPFouCNPJTitular",
      "installments" => "CartaoQtdeParcelas",
      "pre_authorized" => "PreAutorizadaNaPlataforma",
      "exp_date" => "BoletoVencimento"
    }

    attr_reader *@@mappings.keys

    def initialize(attributes = {})
      
      @attributes = attributes
      @attributes.deep_stringify_keys!
      @translated = {}

      @@mappings.each do |k, v|

        if attributes[k]
          instance_variable_set("@#{k}", @translated[v] = attributes[k])
        end

        self.class.send(:define_method, "#{k}=") do |value|
          instance_variable_set("@#{k}",  @translated[v] = value)
        end
      end
    end

    def translated
      { "DadosPedidosFormaPgto" => @translated }
    end
  end
end
