# frozen_string_literal: true

require 'spec_helper'
require 'date'
require './lib/com_thetrainline.rb'

describe ComThetrainline do
  let(:from) { 'London St Pancras International' }
  let(:to) { 'Rotterdam Centraal' }
  let(:departure_at) { DateTime.new(2024, 1, 13) }
  let(:journey) { instance_double('Journey') }
  let(:response_body) { [] }

  describe '.find' do
    before do
      allow(Journey).to receive(:new).and_return(journey)
      allow(journey).to receive(:search).and_return(response_body)
    end

    it 'returns an array' do
      expect(described_class.find(from, to, departure_at)).to match_array(response_body)
    end
  end
end
