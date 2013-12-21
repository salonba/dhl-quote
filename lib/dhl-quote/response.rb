module Shipping
  module DHL
    class Response
      class CannotFetchShippingRate < StandardError; end

      attr_accessor :shipping_charge

      def initialize(response)
        parsed_response = Nokogiri.XML(response.body)
        @shipping_charge = parsed_response.xpath("//ShippingCharge").text

        if @shipping_charge.empty?
          raise CannotFetchShippingRate
        end
      end
    end
  end
end
