# Weather App

This is a Ruby on Rails application that retrieves and displays weather forecasts from the Tomorrow.io API.

## Features

*   Accepts an address as input.
*   Retrieves current weather data for the given address.
*   Displays detailed weather information including:
    *   Current temperature
    *   Feels like temperature
    *   Humidity
    *   Wind speed and direction
    *   Cloud cover
    *   UV index
    *   Precipitation probability
    *   Visibility
*   Caches the forecast details for 30 minutes for all subsequent requests.
*   Displays an indicator if the result is pulled from the cache.

## Technologies Used

*   Ruby on Rails 7
*   Ruby 3.3+
*   Tomorrow.io Weather API (https://www.tomorrow.io/weather-api/). Note: This is a free service but does require registration, if you don't want to do that, let me know and I can send you my API key.

## API Key Setup

To set up the API key, follow these steps:

1.  Run the following command (assuming visual studio code IDE)
    ```
    RAILS_ENV=development EDITOR="code --wait" rails credentials:edit
    ```
2.  Type the following:
    ```
    api_key: 12345
    ```

## Setup

1.  Clone the repository.
2.  Run `bundle install` to install dependencies.
3.  Start the Rails server with `bin/dev`.

## Usage

1.  Enter an address in the input field (uses zip code of address).
2.  Click "Get Forecast" to retrieve the weather forecast.
3.  The forecast details will be displayed below the input form.

## Docs
Docs can be found in `doc/index.html`

## Notes
- I decided not to use models as I felt there was no advantage to using them for the project as it is now. Though it could easily be useful if more features were to be added, I didn't want to over engineer the solution. 
