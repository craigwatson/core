require "timeout"

module Bucky
  module Geolocation
  module_function

    def get_country(ip_address)
      info = Geolocation.get_geoip_info ip_address
      info.country_code if info
    end

    def get_time_zone(country_code)
      country = Country.find_by(alpha2: country_code)
      country.time_zone if country
    end

    # TODO: this is terribly filthy
    # TODO: replace Biggs Gem with Countries
    def get_address_form(country_code, resource)
      model_name = resource.class.model_name.to_s.downcase
      format = Biggs::Format.new(country_code).format_string

      unless format
        # fallback to NZ format if not available for this country
        format = Biggs::Format.new("NZ").format_string
      end

      required_fields = %w(street city)

      field_descriptions = {
        "street" => "Street and Number",
        "city"   => "City",
        "zip"    => "Post code / ZIP code",
        "state"  => "Region / Province / State",
      }

      format.split("\n").map do |line|
        fields = line.scan(/{{(.+?)}}/).flatten - %w(recipient country)
        width = 100.0 / fields.size

        html = fields.map do |field|
          value = resource.localised_address && resource.localised_address.public_send(field)
          %(
            <input id="#{model_name}_localised_address_#{field}" name="#{model_name}[localised_address_attributes][#{field}]" placeholder="#{field_descriptions[field]}" #{'required="required"' if field.in? required_fields} type="text" style="width: #{width}%" value="#{value}">
                    ).strip
        end.join

        "<div>#{html}</div>" if html.present?
      end.join.html_safe
    end

    def get_geoip_info(ip_address)
      url = "#{geoip_url}/json/#{ip_address}"
      geoip = Typhoeus.get(url, timeout: 1).request.response

      unless geoip.success?
        Bugsnag.notify(RuntimeError.new("geoip: unknown error (#{geoip.code})"))
        return
      end

      json = JSON.parse(geoip.body)

      # add currency to JSON structure
      country_code = json.fetch("country_code")
      country = Country.find_by!(alpha2: country_code)
      new_json = json.merge!(currency: country.currency)

      OpenStruct.new(new_json)
    end

    def geoip_url
      "http://127.0.0.1:9999".freeze
    end
  end
end
