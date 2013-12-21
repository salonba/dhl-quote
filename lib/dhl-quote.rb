require 'net/https'
require 'uri'
require 'nokogiri'
require 'time'

autoload :XmlNode, 'vendor/xml_node/lib/xml_node'

require 'dhl-quote/address.rb'
require 'dhl-quote/package.rb'
require 'dhl-quote/request.rb'
require 'dhl-quote/response.rb'
