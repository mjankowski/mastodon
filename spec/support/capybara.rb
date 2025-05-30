# frozen_string_literal: true

Capybara.server_host = 'localhost'
Capybara.server_port = 3000
Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"

Capybara.register_driver(:playwright) do |app|
  Capybara::Playwright::Driver.new(app, browser_type: :firefox, headless: false)
end
Capybara.javascript_driver = :playwright

# Some of the flaky tests seem to be caused by github runners being too slow for the
# default timeout of 2 seconds
Capybara.default_max_wait_time = 15

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, :js, type: :system) do
    driven_by Capybara.javascript_driver
  end
end
