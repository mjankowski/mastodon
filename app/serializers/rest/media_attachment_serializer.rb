# frozen_string_literal: true

class REST::MediaAttachmentSerializer < REST::BaseSerializer
  include RoutingHelper

  attributes :type,
             :description,
             :blurhash

  attribute :id do
    media_attachment.id.to_s
  end

  attribute :url do
    if media_attachment.not_processed?
      nil
    elsif media_attachment.needs_redownload?
      media_proxy_url(media_attachment.id, :original)
    else
      full_asset_url(media_attachment.file.url(:original))
    end
  end

  attribute :remote_url do
    media_attachment.remote_url.presence
  end

  attribute :preview_url do
    if media_attachment.needs_redownload?
      media_proxy_url(media_attachment.id, :small)
    elsif media_attachment.thumbnail.present?
      full_asset_url(media_attachment.thumbnail.url(:original))
    elsif media_attachment.file.styles.key?(:small)
      full_asset_url(media_attachment.file.url(:small))
    end
  end

  attribute :preview_remote_url do
    media_attachment.thumbnail_remote_url.presence
  end

  attribute :text_url do
    media_attachment.local? && media_attachment.shortcode.present? ? medium_url(media_attachment) : nil
  end

  attribute :meta do
    media_attachment.file.meta
  end
end
