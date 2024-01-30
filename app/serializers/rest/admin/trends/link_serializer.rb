# frozen_string_literal: true

class REST::Admin::Trends::LinkSerializer < REST::Trends::LinkSerializer
  attributes :id

  attribute :requires_review do
    link.requires_review?
  end
end
