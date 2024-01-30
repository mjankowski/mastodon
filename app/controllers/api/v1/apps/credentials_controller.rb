# frozen_string_literal: true

class Api::V1::Apps::CredentialsController < Api::BaseController
  def show
    return doorkeeper_render_error unless valid_doorkeeper_token?

    render json: REST::ApplicationSerializer.one(
      doorkeeper_token.application,
      fields: %i(name website vapid_key client_id scopes)
    )
  end
end
