# frozen_string_literal: true

require 'spec_helper'
require 'date'
require './lib/journey_api.rb'

describe JourneyApi do
  let(:from) { 'London St Pancras International' }
  let(:to) { 'Rotterdam Centraal' }
  let(:departure_at) { DateTime.new(2024, 1, 13) }
  let(:connection) { double('Faraday') }
  let(:journey_search_response) { instance_double('Faraday::Response') }
  let(:from_location_response) { instance_double('Faraday::Response') }
  let(:to_location_response) { instance_double('Faraday::Response') }

  let(:st_pancras) do
    JSON.load_file('spec/support/st_pancras.json').to_json
  end

  let(:rotterdam) do
    JSON.load_file('spec/support/rotterdam.json').to_json
  end

  let(:segments) do
    JSON.load_file('spec/support/segments.json').to_json
  end

  describe '#search' do
    subject do
      described_class.new(from: from, to: to).search(departure_at)
    end

    before do
      allow(Faraday).to receive(:new).and_return(connection)
      allow(journey_search_response).to receive(:body).and_return(segments)
      allow(from_location_response).to receive(:body).and_return(st_pancras)
      allow(to_location_response).to receive(:body).and_return(rotterdam)
    end

    context 'when the API is available' do
      before do
        allow(connection).to receive(:get)
          .with("api/locations-search/v2/search?searchTerm=#{from}&locale=en-GB")
          .and_return(from_location_response)

        allow(connection).to receive(:get)
          .with("api/locations-search/v2/search?searchTerm=#{to}&locale=en-GB")
          .and_return(to_location_response)

        allow(connection).to receive(:post).with('api/journey-search')
          .and_return(journey_search_response)
      end

      it 'returns the Trainline response body' do
        expect(subject).to eq(segments)
      end
    end

    context 'when the API is unavailable' do
      before do
        allow(connection).to receive(:get).and_raise(Faraday::ConnectionFailed)
        allow(connection).to receive(:post).and_raise(Faraday::ConnectionFailed)
      end

      it 'returns an empty JSON object' do
        expect(subject).to eq({}.to_json)
      end
    end
  end
end
