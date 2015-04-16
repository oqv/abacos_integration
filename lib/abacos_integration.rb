$:.unshift File.dirname(__FILE__)

require 'abacos'
require 'abacos/helper'
require 'abacos/address'
require 'abacos/customer'
require 'abacos/line'
require 'abacos/payment'
require 'abacos/order'
require 'abacos_integration/configuration'

module AbacosIntegration
  # class << self
  #
  # end
  class Base
    attr_accessor :configuration

    def initialize(config = {})
      config = AbacosIntegration.configuration
      Abacos.key = config.abacos_key
      Abacos.base_path = config.abacos_base_path
      Abacos.base_path_only = config.abacos_base_path_only
    end

  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

end

require 'abacos_integration/product'
require 'abacos_integration/stock'
require 'abacos_integration/order'
require 'abacos_integration/shipment'
