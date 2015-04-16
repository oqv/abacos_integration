module AbacosIntegration
  class Configuration
    attr_accessor :abacos_key
    attr_accessor :abacos_base_path
    attr_accessor :abacos_base_path_only
    attr_accessor :abacos_fetch_price

    def initialize
      @abacos_key = "123"
      @abacos_base_path = "http://200.201.198.251:8119/AbacosWSPlataforma.asmx"
      @abacos_base_path_only = false
      @abacos_fetch_price = false
    end


  end
end
