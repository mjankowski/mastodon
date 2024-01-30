# frozen_string_literal: true

class REST::CustomEmojiSerializer < REST::BaseSerializer
  include RoutingHelper

  # Please update `app/javascript/mastodon/api_types/custom_emoji.ts` when making changes to the attributes

  attributes :shortcode,
             :visible_in_picker

  attribute :url do
    full_asset_url(custom_emoji.image.url)
  end

  attribute :static_url do
    full_asset_url(custom_emoji.image.url(:static))
  end

  attribute :category, if: :category_loaded? do
    custom_emoji.category.name
  end

  def category_loaded?
    custom_emoji.association(:category).loaded? && custom_emoji.category.present?
  end
end
