# frozen_string_literal: true

require 'date'

class Segment
  def initialize(
    from:,
    to:,
    departure_at:,
    arrive_at:,
    changeovers:,
    duration:,
    products:,
    fares:
  )
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
      service_agencies: ['thetrainline'],
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
      data = JSON.parse(trainline_response)['data']
      return {} if data.nil? || data.empty?

      data['journeySearch']['journeys'].map do |_, journey|
        depart_at = DateTime.parse(journey['departAt'])
        next if depart_at < journey_attributes[:departure_at]

        products = []
        segment_fares = []
        journey_legs = journey['legs']

        journey_legs.map do |leg_id|
          products << transport_mode(data, leg_id)
          segment_fares += parse_fares(data, leg_id)
        end

        new(
          from: journey_attributes[:from],
          to: journey_attributes[:to],
          departure_at: depart_at,
          arrive_at: DateTime.parse(journey['arriveAt']),
          changeovers: journey_legs.count - 1,
          duration: journey['duration'],
          products: products.uniq,
          fares: segment_fares
        ).to_h
      end
    end

    private

    def transport_mode(data, leg_id)
      leg_transport_mode = data['journeySearch']['legs'][leg_id]['transportMode']
      transport_modes = data['transportModes']

      transport_modes[leg_transport_mode]['mode']
    end

    def parse_fares(data, leg_id)
      fares = data['journeySearch']['fares']
      alternatives = data['journeySearch']['alternatives']

      fare_legs_with_fare_id(fares, leg_id).map do |fare_leg|
        {
          name: fare_type(data, fare_leg),
          price_in_cents: price_in_cents(alternatives, fare_leg),
          currency: currency_code(alternatives, fare_leg),
          comfort_class: comfort_class(fare_leg)
        }
      end
    end

    def fare_legs_with_fare_id(fares, leg_id)
      fares.flat_map do |fare_id, fare|
        fare['fareLegs'][0].merge('fareId' => fare_id)
      end.select { |fare_leg| fare_leg['legId'] == leg_id }
    end

    def fare_type(data, fare_leg)
      fare_types = data['fareTypes']
      fare_id = fare_leg['fareId']
      fare_type_id = data['journeySearch']['fares'][fare_id]['fareType']

      fare_types[fare_type_id]['name']
    end

    def comfort_class(fare_leg)
      (fare_leg['comfort']['name'] == 'Standard') ? 0 : 1
    end

    def price_in_cents(journey_alternatives, fare_leg)
      (pricing(journey_alternatives, fare_leg)['price']['amount'] * 100).to_i
    end

    def currency_code(journey_alternatives, fare_leg)
      pricing(journey_alternatives, fare_leg)['price']['currencyCode']
    end

    def pricing(journey_alternatives, fare_leg)
      journey_alternatives.flat_map { |_, alt| alt['billableUnits'] }
        .select { |unit| unit['fareLegIds'].include? fare_leg['id'] }
        .first
    end
  end
end
