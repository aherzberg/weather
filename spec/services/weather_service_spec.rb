# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  describe '.extract_zip_code' do
    it 'extracts zip code from address with zip at end' do
      expect(WeatherService.extract_zip_code('123 Main St, Phoenix 85001')).to eq('85001')
    end

    it 'extracts zip code from address with whitespace after zip' do
      expect(WeatherService.extract_zip_code('123 Main St, Phoenix 85001 ')).to eq('85001')
    end

    it 'returns nil when no zip code is present' do
      expect(WeatherService.extract_zip_code('123 Main St, Phoenix, AZ')).to be_nil
    end

    it 'returns nil when zip code is not exactly 5 digits' do
      expect(WeatherService.extract_zip_code('123 Main St, 850011')).to be_nil
      expect(WeatherService.extract_zip_code('123 Main St, 8500')).to be_nil
    end
  end

  describe '.get_forecast' do
    let(:address) { '123 Main St, Phoenix 86002' }
    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }

    before do
      allow(Rails).to receive(:cache).and_return(memory_store)
      Rails.cache.clear
    end

    it 'returns nil for blank address' do
      expect(WeatherService.get_forecast('')).to be_nil
      expect(WeatherService.get_forecast(nil)).to be_nil
    end

    it 'returns nil for address without zip code' do
      expect(WeatherService.get_forecast('123 Main St, Phoenix, AZ')).to be_nil
    end

    it 'returns the cached data when available' do
      mock_response = {
        'data' => {
          'time' => '2025-02-23T20:22:00Z',
          'values' => { 'temperature' => 10 }
        },
        'location' => {
          'lat' => 43.15616989135742,
          'lon' => -75.8449935913086,
          'name' => 'New York United States',
          'type' => 'administrative'
        }
      }

      allow(WeatherService).to receive(:get_forecast_from_api).and_return(mock_response)

      # First call should hit the API
      first_result = WeatherService.get_forecast(address)
      # Second call should use cached data
      second_result = WeatherService.get_forecast(address)

      expect(first_result).to eq(mock_response)
      expect(second_result).to eq(mock_response)
      expect(WeatherService).to have_received(:get_forecast_from_api).once
    end

    it 'fetches data from the API when cache is empty' do
      mock_response = {
        'data' => {
          'time' => '2025-02-23T20:22:00Z',
          'values' => { 'temperature' => 20 }
        },
        'location' => {
          'lat' => 43.15616989135742,
          'lon' => -75.8449935913086,
          'name' => 'New York United States',
          'type' => 'administrative'
        }
      }

      allow(WeatherService).to receive(:get_forecast_from_api).and_return(mock_response)
      result = WeatherService.get_forecast(address)
      expect(WeatherService).to have_received(:get_forecast_from_api).once
      expect(result).to eq(mock_response)
    end
  end

  describe 'error handling' do
    let(:address) { '123 Main St, Phoenix 84512' }

    before do
      allow(Rails.cache).to receive(:fetch).and_return(nil)
      allow(WeatherService).to receive(:get_forecast_from_api).and_raise(StandardError, 'API error')
    end

    it 'returns nil when the API returns an error' do
      expect(WeatherService.get_forecast(address)).to be_nil
    end
  end

  describe 'API interaction' do
    let(:address) { '123 Main St, Phoenix 12345' }
    let(:mock_response) do
      {
        'data' => {
          'time' => '2025-02-23T20:22:00Z',
          'values' => { 'temperature' => 20 }
        },
        'location' => {
          'lat' => 43.15616989135742,
          'lon' => -75.8449935913086,
          'name' => 'New York United States',
          'type' => 'administrative'
        }
      }
    end

    it 'parses the API response correctly' do
      allow(WeatherService).to receive(:get_forecast_from_api).and_return(mock_response)
      forecast = WeatherService.get_forecast(address)
      expect(forecast['data']['values']['temperature']).to eq(20)
    end
  end
end
