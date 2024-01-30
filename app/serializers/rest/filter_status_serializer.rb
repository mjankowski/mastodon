# frozen_string_literal: true

class REST::FilterStatusSerializer < REST::BaseSerializer
  attribute :id do
    filter_status.id.to_s
  end

  attribute :status_id do
    filter_status.status_id.to_s
  end
end
