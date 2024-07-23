# frozen_string_literal: true

require 'rails_helper'

describe Api::RateLimitHeaders do
  controller(ApplicationController) do
    include Api::RateLimitHeaders

    def show
      head 200
    end
  end

  before do
    routes.draw { get 'show' => 'anonymous#show' }
  end

  describe 'rate limiting' do
    context 'when throttling is off' do
      before do
        request.env['rack.attack.throttle_data'] = nil
      end

      it 'does not apply rate limiting' do
        get 'show'

        expect(response.headers['X-RateLimit-Limit']).to be_nil
        expect(response.headers['X-RateLimit-Remaining']).to be_nil
        expect(response.headers['X-RateLimit-Reset']).to be_nil
      end
    end

    context 'when throttling is on' do
      let(:start_time) { DateTime.new(2017, 1, 1, 12, 0, 0).utc }

      before do
        request.env['rack.attack.throttle_data'] = { 'throttle_authenticated_api' => { limit: 100, count: 20, period: 10 } }
        travel_to start_time do
          get 'show'
        end
      end

      it 'applies rate limiting headers' do
        expect(response)
          .to have_http_header('X-RateLimit-Limit', '100')
          .and have_http_header('X-RateLimit-Remaining', '80')
          .and have_http_header('X-RateLimit-Reset', (start_time + 10.seconds).iso8601(6))
      end
    end
  end
end
