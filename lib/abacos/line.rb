class Abacos
  #
  #   {
  #     "DadosPedidosItem" => [{
  #       "CodigoProduto" => "3104376",
  #       "QuantidadeProduto" => 1,
  #       "PrecoUnitario" => 100
  #     }]
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

    @@obj_mappings = {
      "personalizations" => "Abacos::LinePersonalization Personalizacao"
    }

    attr_reader *@@mappings.keys
    attr_reader *@@obj_mappings.keys

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

      @@obj_mappings.each do |k, v|

        klass, translation = v.split

        instance_variable_set("@#{k}", [])

        (attributes[k] || []).each do |line|

          horse_key = 'DadosPedidosItemPersonalizacao' if klass.eql?('Abacos::LinePersonalization')

          instance = klass.constantize.new line
          @translated[translation] ||= {}
          @translated[translation][horse_key] ||= []

          instance_variable_get("@#{k}").push instance
          @translated[translation][horse_key].push instance.translated

        end
      end

    end

    def translated
      @translated
    end
  end
end
