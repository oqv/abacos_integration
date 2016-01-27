class Abacos
  class LinePersonalization
    attr_reader :attributes

    @@mappings = {
      "price_liquid" => "PrecoUnitarioLiquido",
      "price_unit" => "PrecoUnitarioBruto",
      "sku" => "CodigoProdutoPersonalizacao"
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
      @translated
    end
  end
end
