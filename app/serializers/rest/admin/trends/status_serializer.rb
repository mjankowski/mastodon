# frozen_string_literal: true

class REST::Admin::Trends::StatusSerializer < REST::StatusSerializer
  attribute :requires_review do
    status.requires_review?
  end
end
