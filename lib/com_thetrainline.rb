# frozen_string_literal: true

require 'date'
require 'faraday'

class ComThetrainline
  class << self
    def find(from, to, departure_at)
      conn = Faraday.new(
        url: 'http://localhost:9000',
        headers: { 'Content-Type' => 'application/json' }
      )

      response = conn.post('api/journey-search') do |req|
        req.body = { query: '' }.to_json
      end

      puts response.body

      []
    end
  end
end
