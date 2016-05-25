module AbacosIntegration
  class Payment < Base
    attr_reader :update_status_payload

    def initialize(config, payload={})
      super config
      if payload.present?
        parsed_payload = JSON.parse(payload)
        parsed_payload['date'] = Abacos::Helper.parse_timestamp(parsed_payload['date'])

        @update_status_payload = parsed_payload
      end
    end

    def create
      Abacos.update_order_status(@update_status_payload)
    end

  end
end