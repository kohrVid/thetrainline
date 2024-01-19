# frozen_string_literal: true

require 'spec_helper'
require 'date'
require './lib/com_thetrainline.rb'

describe ComThetrainline do
  let(:from) { 'London St Pancras International' }
  let(:to) { 'Rotterdam Centraal' }
  let(:departure_at) { DateTime.new(2024, 1, 13) }
  let(:journey) { instance_double('Journey') }

  let(:response_body) do
    JSON.load_file('spec/support/segments.json').to_json
  end

  describe '.find' do
    before do
      allow(JourneyApi).to receive(:new).and_return(journey)
      allow(journey).to receive(:search).and_return(response_body)
    end

    it 'parses segments' do
      expect(Segment).to receive(:parse_segments)

      described_class.find(from, to, departure_at)
    end

    context 'when the API is unavailable' do
      let(:response_body) { {}.to_json }

      it 'returns an empty JSON object' do
        expect(described_class.find(from, to, departure_at)).to eq({})
      end
    end
  end
end
