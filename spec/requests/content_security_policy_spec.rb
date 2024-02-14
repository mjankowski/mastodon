# frozen_string_literal: true

require 'rails_helper'

describe 'Content-Security-Policy' do
  before { allow(SecureRandom).to receive(:base64).with(16).and_return('ZbA+JmE7+bK8F5qvADZHuQ==') }

  it 'sets the expected CSP headers' do
    get '/'

    expect(response_csp_headers)
      .to match_array(expected_csp_headers)
  end

  def response_csp_headers
    response
      .headers['Content-Security-Policy']
      .split(';')
      .map(&:strip)
  end

  def expected_csp_headers
    <<~CSP.split("\n").map(&:strip)
      base-uri 'none'
      child-src 'self' blob: https://mastodon.example
      connect-src 'self' data: blob: https://mastodon.example #{Rails.configuration.x.streaming_api_base_url}
      default-src 'none'
      font-src 'self' https://mastodon.example
      form-action 'self'
      frame-ancestors 'none'
      frame-src 'self' https:
      img-src 'self' data: blob: https://mastodon.example
      manifest-src 'self' https://mastodon.example
      media-src 'self' data: https://mastodon.example
      script-src 'self' https://mastodon.example 'wasm-unsafe-eval'
      style-src 'self' https://mastodon.example 'nonce-ZbA+JmE7+bK8F5qvADZHuQ=='
      worker-src 'self' blob: https://mastodon.example
    CSP
  end
end
