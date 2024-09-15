# frozen_string_literal: true

class Auth::Sessions::SecurityKeyOptionsController < ApplicationController
  skip_before_action :check_self_destruct!
  skip_before_action :require_functional!
  skip_before_action :update_user_sign_in

  before_action :credentials_not_enabled, unless: -> { user_from_attempt&.webauthn_enabled? }

  def show
    store_session_challenge
    render json: credential_options, status: 200
  end

  private

  def credentials_not_enabled
    render json: { error: t('webauthn_credentials.not_enabled') }, status: 401
  end

  def user_from_attempt
    @user_from_attempt ||= User.find_by(id: session[:attempt_user_id])
  end

  def store_session_challenge
    session[:webauthn_challenge] = credential_options.challenge
  end

  def credential_options
    @credential_options ||= WebAuthn::Credential.options_for_get(
      allow: user_credential_ids,
      user_verification: 'discouraged'
    )
  end

  def user_credential_ids
    user_from_attempt
      .webauthn_credentials
      .pluck(:external_id)
  end
end
