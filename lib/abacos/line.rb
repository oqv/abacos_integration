class Abacos
  #
  #   {
  #     "DadosPedidosItem" => {
  #       "CodigoProduto" => "3104376",
  #       "QuantidadeProduto" => 1,
  #       "PrecoUnitario" => 100
  #     }
  #   }
  #
  class Line
    attr_reader :attributes

    @@mappings = {
      "sku" => "CodigoProduto",
      "quantity" => "QuantidadeProduto",
      "price" => "PrecoUnitario",
      "is_gift" => "EmbalagemPresente",
      "gift_message" => "MensagemPresente",
      "price_unit" => "PrecoUnitarioBruto",
      "is_freebie" => "Brinde",
      "price_ref" => "ValorReferencia"
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
      { "DadosPedidosItem" => @translated }
    end
  end
end
