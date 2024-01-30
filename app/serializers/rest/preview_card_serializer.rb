# frozen_string_literal: true

class REST::PreviewCardSerializer < REST::BaseSerializer
  include RoutingHelper

  attributes :title, :description, :language, :type,
             :author_name, :author_url, :provider_name,
             :provider_url, :width, :height,
             :image_description, :embed_url, :blurhash, :published_at

  attribute :url do
    preview_card.original_url.presence || preview_card.url
  end

  attribute :image do
    preview_card.image? ? full_asset_url(preview_card.image.url(:original)) : nil
  end

  attribute :html do
    Sanitize.fragment(preview_card.html, Sanitize::Config::MASTODON_OEMBED)
  end
end
