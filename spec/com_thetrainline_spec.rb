# frozen_string_literal: true

require 'spec_helper'
require 'date'
require './lib/com_thetrainline.rb'

describe ComThetrainline do
  let(:from) { 'London St Pancras International' }
  let(:to) { 'Rotterdam Centraal' }
  let(:departure_at) { DateTime.new(2024, 1, 13) }

  describe '.find' do
    it 'returns an array' do
      expect(described_class.find(from, to, departure_at)).to match_array([])
    end
  end
end
