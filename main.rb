# frozen_string_literal: true

require 'date'
require './lib/com_thetrainline.rb'

from = 'Ashchurch For Tewkesbury'
to = 'Ash'
departure_at = DateTime.new(2023, 12, 1, 7, 1)
puts ComThetrainline.find(from, to, departure_at)
