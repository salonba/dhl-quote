module Shipping
  module DHL
    class Request
      class Configuration
        attr_accessor :uri, :site_id, :password
      end

      class << self
        attr_accessor :configuration
      end

      def self.configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end

      def shipping_rates(from, to, shipment_weight=nil, packages=[])
        post_body = build_rate_request(from, to, shipment_weight, packages)
        uri = URI.parse(Request.configuration.uri)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(uri.request_uri)
        request.body = post_body
        request["Content-Type"] = "text/xml"

        response = http.request(request)
        Response.new(response)
      end

      # ready times are only 8a-5p(17h)
      def ready_time(time=Time.now)
        if time.hour >= 17 || time.hour < 8
          time.strftime("PT08H00M")
        else
          time.strftime("PT%HH%MM")
        end
      end

      # ready dates are only mon-fri
      def ready_date(t=Time.now)
        date = Date.parse(t.to_s)
        if (date.cwday >= 6) || (date.cwday >= 5 && t.hour >= 17)
          date.send(:next_day, 8-date.cwday)
        else
          date
        end.strftime("%Y-%m-%d")
      end

      def build_rate_request(from, to, shipment_weight, packages)
        root = XmlNode.new('p:DCTRequest', 'xmlns:p' => 'http://www.dhl.com', 'xmlns:p1' => 'http://www.dhl.com/datatypes', 'xmlns:p2' => 'http://www.dhl.com/DCTRequestdatatypes', 'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation' => 'http://www.dhl.com DCT-req.xsd') do |xml|
          xml << XmlNode.new('GetQuote') do |quote|
            quote << generate_request_header
            quote << generate_from(from)
            quote << generate_shipment(shipment_weight, packages)
            quote << generate_to(to)
          end
        end      

        root.to_s
      end

      # generate request header
      def generate_request_header
        XmlNode.new('Request') do |request|
          request << XmlNode.new('ServiceHeader') do |header|
            header << XmlNode.new('SiteID', Request.configuration.site_id)
            header << XmlNode.new('Password', Request.configuration.password)
          end
        end
      end

      # generate shipping origin info
      def generate_from(address)
        XmlNode.new('From') do |shipper|
          shipper << XmlNode.new('CountryCode', address.country_code)
          shipper << XmlNode.new('Postalcode', address.zip_code)
          shipper << XmlNode.new('City', address.city)
        end
      end

      # generate shipping destination info
      def generate_to(address)
        XmlNode.new('To') do |to|
          to << XmlNode.new('CountryCode', address.country_code)
          to << XmlNode.new('Postalcode', address.zip_code)
          to << XmlNode.new('City', address.city)
        end
      end

      # generate shipment details, packages info
      def generate_shipment(shipment_weight, packages)
        XmlNode.new('BkgDetails') do |details|
          details << XmlNode.new('PaymentCountryCode', 'US')
          details << XmlNode.new('Date', ready_date)
          details << XmlNode.new('ReadyTime', ready_time)
          details << XmlNode.new('ReadyTimeGMTOffset', '+00:00')
          details << XmlNode.new('DimensionUnit', 'CM')
          details << XmlNode.new('WeightUnit', 'KG')
          details << XmlNode.new('ShipmentWeight', shipment_weight)

          unless packages.empty?
            details << XmlNode.new('Pieces') do |pieces|
              packages.each do |package|
                pieces << XmlNode.new('Piece') do |piece|
                  piece << XmlNode.new('PieceID', package.piece_id)
                  piece << XmlNode.new('Height', package.height)
                  piece << XmlNode.new('Depth', package.depth)
                  piece << XmlNode.new('Width', package.width)
                  piece << XmlNode.new('Weight', package.weight)
                end
              end
            end
          end
        end
      end
    end
  end
end
