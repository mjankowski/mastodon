# frozen_string_literal: true

RSpec::Matchers.define :have_http_header do |header, values|
  match do |response|
    expect(response.headers[header]).to include(values)
  end

  failure_message do |response|
    "Expected that `#{header}` would have values of `#{values}` but was `#{response.headers[header]}`"
  end
end
