# frozen_string_literal: true

class Api::V1::AppsController < Api::BaseController
  skip_before_action :require_authenticated_user!

  PERMITTED_PARAMS = [
    :client_name,
    :redirect_uris,
    :scopes,
    :website,
    redirect_uris: [],
    scopes: [],
  ].freeze

  def create
    @app = Doorkeeper::Application.create!(application_options)
    render json: @app, serializer: REST::CredentialApplicationSerializer
  end

  private

  def application_options
    {
      name: app_params[:client_name],
      redirect_uri: app_params[:redirect_uris],
      scopes: app_scopes_or_default,
      website: app_params[:website],
    }
  end

  def app_scopes_or_default
    Array(app_params[:scopes]).first || Doorkeeper.configuration.default_scopes
  end

  def app_params
    params
      .slice(*PERMITTED_PARAMS)
      .permit(*PERMITTED_PARAMS)
  end
end
