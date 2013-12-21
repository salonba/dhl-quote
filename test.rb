require 'dhl-quote'

Shipping::DHL::Request.configure do |config|
  config.uri = "https://xmlpitest-ea.dhl.com/XMLShippingServlet"
  config.site_id = "wakefield"
  config.password = "h1ns2345"
end

dhl = Shipping::DHL::Request.new

package = Shipping::Package.new({piece_id: 1, height: 2, depth: 2, width: 2, weight: 10})
from = Shipping::Address.new({country_code: 'BA', zip_code: '71000', city: 'Sarajevo'})
to = Shipping::Address.new({country_code: 'BA', zip_code: '71000', city: 'Sarajevo'})

puts dhl.shipping_rates(package, from, to).shipping_charge
