# frozen_string_literal: true

require 'date'

class Segment
  def initialize(from:, to:, departure_at:, arrive_at:, changeovers:, duration:, products:, fares:)
    @from = from
    @to = to
    @departure_at = departure_at
    @arrive_at = arrive_at
    @changeovers = changeovers
    @duration = duration
    @products = products
    @fares = fares
  end

  def to_h
    {
      departure_station: @from,
      departure_at: @departure_at,
      arrival_station: @to,
      arrival_at: @arrive_at,
      service_agencies: ["thetrainline"],
      duration_in_minutes: duration_in_minutes(@duration),
      changeovers: @changeovers,
      products: @products,
      fares: @fares
    }
  end

  private

  def duration_in_minutes(duration)
    hours = duration.scan(/PT(\d)H/)[0][0].to_i
    mins = duration.scan(/.*H(\d.*)M/)[0][0].to_i

    (hours * 60) + mins
  end

  class << self
    def parse_segments(journey_attributes, trainline_response)
      data = JSON.parse(trainline_response)["data"]

      return {} if data.nil? || data.empty?

      segments = []

      data["journeySearch"]["journeys"].each do |id, journey|
        depart_at = DateTime.parse(journey["departAt"])
        next if depart_at < journey_attributes[:departure_at]

        journey_legs = journey["legs"]

        all_legs = data["journeySearch"]["legs"]
        alternatives = data["journeySearch"]["alternatives"]
        fares = data["journeySearch"]["fares"]
        carriers = data["carriers"]
        fare_types = data["fareTypes"]
        transport_modes = data["transportModes"]
        products = []
        segment_fares = []

        journey_legs.map do |leg_id|
          leg = all_legs[leg_id]
          transport_mode = transport_modes[leg["transportMode"]]["mode"]
          products << transport_mode
          fare_legs_with_fare_ids = fares.flat_map { |fare_id, fare| fare["fareLegs"][0].merge(fare_id: fare_id) }
          fare_legs = fare_legs_with_fare_ids.select { |fare_leg| fare_leg["legId"] == leg_id }

          fare_legs.each do |fare_leg|
            comfort_class = (fare_leg["comfort"]["name"] == "Standard") ? 0 : 1
            pricing = alternatives.flat_map{|_, alternative| alternative["billableUnits"]}.select {|unit| unit["fareLegIds"].include? fare_leg["id"] }.first

            fare_type = fare_types[fares[fare_leg[:fare_id]]["fareType"]]["name"]
            segment_fares << {
              name: fare_type,
              price_in_cents: (pricing["price"]["amount"] * 100).to_i,
              currency: pricing["price"]["currencyCode"],
              comfort_class: comfort_class
            }
          end

          fare_id = fares

        end

        segments << new(
          from: journey_attributes[:from],
          to: journey_attributes[:to],
          departure_at: depart_at,
          arrive_at: DateTime.parse(journey["arriveAt"]),
          changeovers: journey_legs.count - 1,
          duration: journey["duration"],
          products: products.uniq,
          fares: segment_fares
        )
      end

      segments.map(&:to_h)
    end
  end
end
