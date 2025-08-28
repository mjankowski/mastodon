# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Health check endpoint' do
  describe 'GET /health' do
    context 'without format specified' do
      it 'returns plain text response' do
        get health_path

        expect(response)
          .to have_http_status(200)
        expect(response.body)
          .to include('OK')
        expect(response.media_type)
          .to eq('text/plain')
      end
    end

    context 'with HTML format' do
      it 'returns HTML page' do
        get health_path(format: :html)

        expect(response)
          .to have_http_status(200)
        expect(response.media_type)
          .to eq('text/html')
      end
    end
  end
end
