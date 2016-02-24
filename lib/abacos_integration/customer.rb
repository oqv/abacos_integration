module AbacosIntegration
  class Customer < Base

    @@mappings = {
      "email" => "EMail",
      "cpf" => "CPFouCNPJ",
      "kind" => "TipoPessoa",
      "gender" => "Sexo",
      "birth_date" => "DataNascimento",
      "rg" => "Documento",
      "phone" => "Celular",
    }

    @@obj_mappings = {
      "billing_address" => "Abacos::Address EndCobranca",
      "shipping_address" => "Abacos::Address EndEntrega",
      "main_address" => "Abacos::Address Endereco"
    }

    @@composed_mappings = {
      "first_name last_name" => "Nome"
    }

    attr_reader *@@mappings.keys
    attr_reader *@@obj_mappings.keys
    attr_reader *@@composed_mappings.keys.map(&:split).flatten

    def initialize(config = {}, attributes = {})
      super config
      @attributes = attributes
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
        if attributes[k]
          instance = klass.constantize.new attributes[k]

          instance_variable_set("@#{k}", instance) 
          @translated[translation] = instance.translated
        end
      end

      @@composed_mappings.each do |k, v|
        @translated[v] = k.split.inject("") do |string, part|
          if attributes[part]
            instance_variable_set("@#{part}", attributes[part]) 
            string << " " + attributes[part] 
          end

          string.strip! || string
        end
      end
    end

    def first_name=(value)
      @firstname = value
    end

    def billing_address=(address)
      @billing_address = Abacos::Address.new(address)
      @translated["EndCobranca"] = @billing_address.translated
      @billing_address
    end

    def shipping_address=(address)
      @shipping_address = Abacos::Address.new(address)
      @translated["EndEntrega"] = @billing_address.translated
      @shipping_address
    end

    def main_address=(address)
      @main_address = Abacos::Address.new(address)
      @translated["Endereco"] = @billing_address.translated
      @main_address
    end

    def translated
      { "DadosClientes" => @translated }
    end

    def send_customer
      Abacos.add_customers([translated])
    end

  end
end