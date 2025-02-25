# frozen_string_literal: true

class WeatherController < ApplicationController
  
  # Retrieves the weather forecast for a given address.
  def index
    @address = params[:address]

    if @address.present?
      zip_code = WeatherService.extract_zip_code(@address)
      @cached = Rails.cache.exist?("weather_forecast:#{zip_code}")
      @forecast = WeatherService.get_forecast(zip_code)
    end
  end
end
