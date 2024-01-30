# frozen_string_literal: true

class REST::Admin::Trends::Links::PreviewCardProviderSerializer < REST::BaseSerializer
  attributes(
    :domain,
    :id,
    :requested_review_at,
    :reviewed_at,
    :trendable
  )

  attribute :requires_review do
    preview_card_provider.requires_review?
  end
end
