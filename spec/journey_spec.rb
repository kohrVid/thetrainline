# frozen_string_literal: true

require 'date'
require 'spec_helper'
require './lib/com_thetrainline'

describe Journey do
  let(:departure_at) { DateTime.new(2024, 1, 13) }
  let(:response) { instance_double('Faraday::Response') }
  let(:response_body) { {} }
  let(:connection) { double('Faraday') }

  before do
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive(:post).with('api/journey-search').and_return(response)
    allow(response).to receive(:body).and_return(response_body)
  end

  describe '#search' do
    subject do
      described_class.new(
        origin_urn: 'urn:trainline:generic:loc:ASC4700gb',
        destination_urn: 'urn:trainline:generic:loc:ASH5641gb'
      ).search(departure_at)
    end

    it 'returns the Trainline response body' do
      expect(subject).to eq(response_body)
    end
  end
end
