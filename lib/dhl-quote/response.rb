module Shipping
  module DHL
    class Response
      class CannotFetchShippingRate < StandardError; end

      attr_accessor :shipping_charge

      def initialize(response)
        puts "---------"
        puts response.body
        puts "---------"
        parsed_response = Nokogiri.XML(response.body)
        @shipping_charge = parsed_response.xpath("//ShippingCharge").text

        if @shipping_charge.empty?
          error_message = parsed_response.xpath("//ConditionData").text
          raise CannotFetchShippingRate, error_message
        end
      end
    end
  end
end
