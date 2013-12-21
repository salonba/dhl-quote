module Shipping
  class Address
    attr_reader :country_code, :zip_code, :city, :address_line

    def initialize(options={})
      @country_code = options[:country_code]
      @zip_code = options[:zip_code]
      @city = options[:city]
      @address_line = options[:address_line]
    end
  end
end
