# frozen_string_literal: true

require 'spec_helper'
require 'date'
require 'json'
require './lib/segment.rb'

describe Segment do
  let(:from) { 'London St Pancras International' }
  let(:to) { 'Rotterdam Centraal' }
  let(:departure_at) { DateTime.new(2024, 1, 13, 10, 30) }
  let(:arrive_at) { DateTime.new(2024, 1, 13, 13, 50) }
  
  let(:fares) do
    [
      {
        name: 'Standard',
        price_in_cents: 23591,
        currency: 'GBP',
        comfort_class: 0
      },
      {
        name: 'Standard Premier',
        price_in_cents: 19025,
        currency: 'GBP',
        comfort_class: 0
      }
    ]
  end

  describe '#to_h' do
    subject do
      described_class.new(
        from: from,
        to: to,
        departure_at: departure_at,
        arrive_at: arrive_at,
        changeovers: 1,
        duration: "PT3H20M",
        products: ["train"],
        fares: fares
      ).to_h
    end

    it 'returns a correctly formatted hash' do
      expect(subject).to eq(
        {
          departure_station: from,
          departure_at: departure_at,
          arrival_station: to,
          arrival_at: arrive_at,
          service_agencies: ["thetrainline"],
          duration_in_minutes: 200,
          changeovers: 1,
          products: ["train"],
          fares: fares 
        }
      )
    end
  end

  describe '.parse_segments' do
    subject do
      described_class.parse_segments(
        journey_attributes,
        trainline_response
      )
    end

    let(:trainline_response) do
      JSON.load_file('spec/support/segments.json').to_json
    end

    let(:journey_attributes) do
      {
        from: from,
        to: to,
        departure_at: departure_at
      }
    end
  
    let(:fares) do
      [
        {
          name: 'Standard',
          price_in_cents: 14400,
          currency: 'EUR',
          comfort_class: 0
        },
        {
          name: 'Standard Premier',
          price_in_cents: 15700,
          currency: 'EUR',
          comfort_class: 0
        },
        {
          name: 'Business Premier Amsterdam',
          price_in_cents: 38525,
          currency: 'EUR',
          comfort_class: 0
        }
      ]
    end

    it 'returns the correct number of segments' do
      expect(subject.count).to eq(7)
    end

    it 'returns a segment with the corrrect format' do
      expect(subject[0]).to eq(
        {
          departure_station: from,
          departure_at: DateTime.new(2024, 1, 19, 6, 16, 0),
          arrival_station: to,
          arrival_at: DateTime.new(2024, 1, 19, 10, 32, 0, '+1'),
          service_agencies: ["thetrainline"],
          duration_in_minutes: 180+16,
          changeovers: 0,
          products: ["train"],
          fares: fares 
        }
      )
    end
  end
end

