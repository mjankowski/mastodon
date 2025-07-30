# frozen_string_literal: true

class Api::V1::Apps::CredentialsController < Api::BaseController
  before_action -> { doorkeeper_render_error }, unless: :valid_doorkeeper_token?

  def show
    render json: doorkeeper_token.application, serializer: REST::ApplicationSerializer
  end
end
