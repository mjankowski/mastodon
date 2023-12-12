# frozen_string_literal: true

class AccountsController < ApplicationController
  include AccountControllerConcern
  include SignatureAuthentication

  vary_by -> { public_fetch_mode? ? 'Accept, Accept-Language, Cookie' : 'Accept, Accept-Language, Cookie, Signature' }

  before_action :require_account_signature!, if: -> { request.format == :json && authorized_fetch_mode? }

  skip_around_action :set_locale, if: -> { request.format == :json }
  skip_before_action :require_functional!, unless: :limited_federation_mode?

  def show
    respond_to do |format|
      format.html do
        expires_in(15.seconds, public: true, stale_while_revalidate: 30.seconds, stale_if_error: 1.hour) unless user_signed_in?
      end

      format.json do
        expires_in 3.minutes, public: !(authorized_fetch_mode? && signed_request_account.present?)
        render_with_cache json: @account, content_type: 'application/activity+json', serializer: ActivityPub::ActorSerializer, adapter: ActivityPub::Adapter
      end
    end
  end

  private

  def username_param
    params[:username]
  end

  def skip_temporary_suspension_response?
    request.format == :json
  end

  def rss_url
    if tag_requested?
      short_account_tag_url(@account, params[:tag], format: 'rss')
    else
      short_account_url(@account, format: 'rss')
    end
  end
  helper_method :rss_url

  def tag_requested?
    path_without_format.end_with?(Addressable::URI.parse("/tagged/#{params[:tag]}").normalize)
  end

  def path_without_format
    request.path.split('.').first
  end
end
