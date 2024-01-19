# frozen_string_literal: true

require 'date'
require 'faraday'
require './lib/journey_api.rb'
require './lib/segment.rb'

class ComThetrainline
  class << self
    def find(from, to, departure_at)
      journey = JourneyApi.new(from: from, to: to)
      trainline_response = journey.search(departure_at)

      journey_attributes = {
        from: from,
        to: to,
        departure_at: departure_at
      }

      Segment.parse_segments(journey_attributes, trainline_response)
    end
  end
end
