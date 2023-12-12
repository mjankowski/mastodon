# frozen_string_literal: true

class Accounts::StatusesController < ApplicationController
  PAGE_SIZE = 20
  PAGE_SIZE_MAX = 200

  include AccountControllerConcern

  vary_by -> { public_fetch_mode? ? 'Accept, Accept-Language, Cookie' : 'Accept, Accept-Language, Cookie, Signature' }

  skip_around_action :set_locale
  skip_before_action :require_functional!, unless: :limited_federation_mode?

  before_action :set_statuses

  def index
    respond_to do |format|
      format.rss do
        expires_in 1.minute, public: true
      end
    end
  end

  private

  def set_statuses
    @statuses = cache_collection(filtered_limited_statuses, Status)
  end

  def limit_or_default
    params[:limit].present? ? [params[:limit].to_i, PAGE_SIZE_MAX].min : PAGE_SIZE
  end

  def filtered_limited_statuses
    filtered_statuses.without_reblogs.limit(limit_or_default)
  end

  def filtered_statuses
    default_statuses.tap do |statuses|
      statuses.merge!(hashtag_scope) if tag_requested?
      statuses.merge!(only_media_scope) if media_requested?
      statuses.merge!(no_replies_scope) unless replies_requested?
    end
  end

  def default_statuses
    @account.statuses.where(visibility: [:public, :unlisted])
  end

  def only_media_scope
    Status.joins(:media_attachments).merge(@account.media_attachments).group(:id)
  end

  def no_replies_scope
    Status.without_replies
  end

  def hashtag_scope
    if requested_tag
      Status.tagged_with(requested_tag.id)
    else
      Status.none
    end
  end

  def requested_tag
    Tag.find_normalized(params[:tag])
  end

  def username_param
    params[:username]
  end

  def media_requested?
    path_without_format.end_with?('/media') && !tag_requested?
  end

  def replies_requested?
    path_without_format.end_with?('/with_replies') && !tag_requested?
  end

  def tag_requested?
    path_without_format.end_with?(Addressable::URI.parse("/tagged/#{params[:tag]}").normalize)
  end

  def path_without_format
    request.path.split('.').first
  end
end
