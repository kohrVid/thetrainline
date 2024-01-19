# frozen_string_literal: true

require 'faraday'

class JourneyApi
  def initialize(from:, to:, passengers: [], locale: 'en-GB')
    @from = from
    @to = to
    @passengers = passengers
    @locale = locale

    @conn = Faraday.new(
      url: ENV.fetch('TRAINLINE_HOST', 'http://localhost:9000'),
      headers: { 'Content-Type': 'application/json' }
    )
  end

  def search(departure_at)
    @origin_urn = location_code(@from)
    @destination_urn = location_code(@to)

    response = @conn.post('api/journey-search') do |req|
      req.body = body(departure_at).to_json
    end

    response.body

  rescue Faraday::ConnectionFailed, Errno::ECONNREFUSED
    return {}.to_json
  end

  private

  def location_code(search_term)
    response = @conn.get(
      "api/locations-search/v2/search?searchTerm=#{search_term}&locale=#{@locale}"
    )

    JSON.parse(response.body)['searchLocations'][0]['code']
  end

  def body(departure_at)
    {
      'passengers': passengers,
      'isEurope': true,
      'cards': [],
      'transitDefinitions': [
        {
          'direction': 'outward',
          'origin': @origin_urn,
          'destination': @destination_urn,
          'journeyDate': {
            'type': 'departAfter',
            'time': departure_at.strftime("%Y-%m-%dT%H:%M:%S")
          }
        }
      ],
      'type': 'single',
      'maximumJourneys': 5,
      'includeRealtime': true,
      'transportModes': ['mixed'],
      'directSearch': false,
      'composition': ['through', 'interchangeSplit']
    }
  end

  def passengers
    if @passengers.empty?
      return [
        {
          'id': '55220bcd-b59a-4078-a606-b716cd609dc6',
          'dateOfBirth': '1991-01-17',
          'cardIds': []
        }
      ]
    end

    @passengers.map do |passenger|
      {
        'id': passenger.id,
        'dateOfBirth': passenger.date_of_birth,
        'cardIds': passenger.card_ids
      }
    end
  end
end
