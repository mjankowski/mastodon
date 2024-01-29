# frozen_string_literal: true

class REST::MarkerSerializer < REST::BaseSerializer
  attributes :last_read_id, :version, :updated_at

  def last_read_id
    object.last_read_id.to_s
  end

  def version
    object.lock_version
  end
end
