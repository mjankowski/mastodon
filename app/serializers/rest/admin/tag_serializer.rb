# frozen_string_literal: true

class REST::Admin::TagSerializer < REST::TagSerializer
  attributes(
    :listable,
    :trendable,
    :usable
  )

  attribute :id do
    tag.id.to_s
  end

  attribute :requires_review do
    tag.requires_review?
  end
end
