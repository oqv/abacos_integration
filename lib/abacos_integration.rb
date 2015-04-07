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

    def initialize(config = {})
      config = {}
      config[:abacos_key] = "123"
      config[:abacos_base_path] = "http://187.120.13.174:8045/WSPlataforma"
      @config = config

      Abacos.key = config[:abacos_key]
      Abacos.base_path = config[:abacos_base_path]
      Abacos.base_path_only = config[:abacos_base_path_only].to_s == "true" || config[:abacos_base_path_only].to_s == "1"
    end
  end
end

require 'abacos_integration/product'
require 'abacos_integration/stock'
require 'abacos_integration/order'
require 'abacos_integration/shipment'
