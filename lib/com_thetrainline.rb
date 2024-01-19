# frozen_string_literal: true

require 'date'
require 'faraday'
require './lib/journey_api.rb'

class ComThetrainline
  class << self
    def find(from, to, departure_at)
      journey = JourneyApi.new(from: from, to: to)
      trainline_response = journey.search(departure_at)
    end
  end
end
