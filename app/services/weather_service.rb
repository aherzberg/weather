# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'zlib'

# This class provides a service to retrieve weather forecasts from the Tomorrow.io API.
class WeatherService
  # Extracts the zip code from an address string.
  # @param address [String] The address to extract the zip code from.
  # @return [String, nil] The zip code or nil if not found.
  def self.extract_zip_code(address)
    # Match exactly 5 digit word at end of line
    zip_match = address.strip.match(/\b\d{5}$/)
    zip_match ? zip_match[0] : nil
  end

  # Retrieves the weather forecast for a given address.
  # @param address [String] The address to get the forecast for.
  # @return [Hash, nil] The forecast data or nil if an error occurs.
  def self.get_forecast(address)
    return nil if address.blank?

    zip_code = extract_zip_code(address)
    return nil if zip_code.nil?

    Rails.cache.fetch("weather_forecast:#{zip_code}", expires_in: 30.minutes) do
      get_forecast_from_api(address)
    end
  end

  # Retrieves the forecast data from the Tomorrow.io API.
  # @param address [String] The address to get the forecast for.
  # @return [Hash, nil] The forecast data or nil if an error occurs.
  def self.get_forecast_from_api(address)
    zip_code = extract_zip_code(address)
    return nil unless zip_code

    api_key = Rails.application.credentials.api_key
    uri = URI('https://api.tomorrow.io/v4/weather/realtime')
    uri.query = URI.encode_www_form({
                                      location: "#{zip_code} US",
                                      apikey: api_key,
                                      units: 'imperial'
                                    })

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request['accept'] = 'application/json'
    request['accept-encoding'] = 'gzip'

    response = http.request(request)
    case response['content-encoding']
    when 'gzip'
      Rails.logger.info 'API Response: Gzipped'
      body = Zlib::GzipReader.new(StringIO.new(response.body)).read
    else
      body = response.body
    end
    Rails.logger.info "API Response: #{body}"
    JSON.parse(body)
  rescue StandardError => e
    Rails.logger.error "Error fetching weather data: #{e.message}"
    Rails.logger.error "Address: #{address}"
    nil
  end
end
