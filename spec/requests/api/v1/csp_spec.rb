# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'API namespace minimal Content-Security-Policy' do
  before { stub_tests_controller }

  around do |example|
    with_routing do |set|
      set.draw { get '/api/v1/tests', to: 'api/v1/tests#index' }
      example.run
    end
  end

  it 'returns the correct CSP headers' do
    get '/api/v1/tests'

    expect(response).to have_http_status(200)
    expect(response.headers['Content-Security-Policy']).to eq(minimal_csp_headers)
  end

  private

  def stub_tests_controller
    stub_const('Api::V1::TestsController', api_tests_controller)
  end

  def api_tests_controller
    Class.new(Api::BaseController) do
      def index
        head 200
      end

      private

      def user_signed_in? = false
      def current_user = nil
    end
  end

  def minimal_csp_headers
    "default-src 'none'; frame-ancestors 'none'; form-action 'none'"
  end
end
