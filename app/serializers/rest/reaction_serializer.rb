# frozen_string_literal: true

class REST::ReactionSerializer < REST::BaseSerializer
  include RoutingHelper

  attributes :name

  attribute :me, if: :current_user?

  attribute :count do
    reaction.respond_to?(:count) ? reaction.count : 0
  end

  def custom_emoji?
    reaction.custom_emoji.present?
  end

  attribute :url, if: :custom_emoji? do
    full_asset_url(reaction.custom_emoji.image.url)
  end

  attribute :static_url, if: :custom_emoji? do
    full_asset_url(reaction.custom_emoji.image.url(:static))
  end
end
