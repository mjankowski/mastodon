# frozen_string_literal: true

class Api::V1::CustomEmojisController < Api::BaseController
  vary_by '', unless: :disallow_unauthenticated_api_access?

  def index
    cache_even_if_authenticated! unless disallow_unauthenticated_api_access?
    # TODO: eh?!
    render_with_cache json: REST::CustomEmojiSerializer.many(CustomEmoji.listed.includes(:category))
  end
end
