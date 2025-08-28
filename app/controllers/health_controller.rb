# frozen_string_literal: true

class HealthController < Rails::HealthController
  before_action :handle_default, if: -> { request.format.text? }
  content_security_policy false, if: -> { request.format.html? }

  private

  def handle_default
    render plain: 'OK'
  end
end
