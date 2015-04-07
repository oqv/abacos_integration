$:.unshift File.dirname(__FILE__)

require 'abacos'
require 'abacos/helper'
require 'abacos/address'
require 'abacos/customer'
require 'abacos/line'
require 'abacos/payment'
require 'abacos/order'

module AbacosIntegration
  class Base
    attr_reader :config
    mattr_accessor :key
    @@key = "123"

    mattr_accessor :products_wsdl
    @@products_wsdl = "http://187.120.13.174:8045/AbacosWSProdutos.asmx"

    mattr_accessor :base_path
    @@base_path = "http://187.120.13.174:8045/WSPlataforma"

    mattr_accessor :des3_key
    @@des3_key = "122318298301283812932133"

    mattr_accessor :des3_iv
    @@des3_iv = "122318298301283812932133"

    def initialize(config = {})
      @config = config

      Abacos.key = @@key#config[:abacos_key]
      Abacos.base_path = @@base_path#config[:abacos_base_path]
      Abacos.base_path_only = config[:abacos_base_path_only].to_s == "true" || config[:abacos_base_path_only].to_s == "1"
    end

    def self.setup
      yield self
    end
  end
end

require 'abacos_integration/product'
require 'abacos_integration/stock'
require 'abacos_integration/order'
require 'abacos_integration/shipment'
