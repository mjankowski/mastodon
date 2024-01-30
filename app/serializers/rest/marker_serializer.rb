# frozen_string_literal: true

class REST::MarkerSerializer < REST::BaseSerializer
  attributes :updated_at

  attribute :last_read_id do
    marker.last_read_id.to_s
  end

  attribute :version do
    marker.lock_version
  end
end
