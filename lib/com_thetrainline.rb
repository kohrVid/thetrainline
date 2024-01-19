# frozen_string_literal: true

require 'date'
require 'faraday'
require './lib/journey.rb'

class ComThetrainline
  class << self
    def find(from, to, departure_at)
      journey = Journey.new(
        origin_urn: 'urn:trainline:generic:loc:ASC4700gb',
        destination_urn: 'urn:trainline:generic:loc:ASH5641gb'
      )

      journey.search(departure_at)
    end
  end
end
