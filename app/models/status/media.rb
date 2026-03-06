# frozen_string_literal: true

module Status::Media
  extend ActiveSupport::Concern

  MEDIA_ATTACHMENTS_LIMIT = 4

  included do
    has_many :media_attachments, dependent: :nullify

    scope :without_empty_attachments, -> { where(ordered_media_attachment_ids: nil).or(where.not(ordered_media_attachment_ids: [])) }
  end

  def with_media?
    ordered_media_attachments.any?
  end

  def ordered_media_attachments
    if ordered_media_attachment_ids.nil?
      # Sort with Ruby to avoid hitting DB when status not persisted yet
      media_attachments.sort_by(&:id)
    else
      map = media_attachments.index_by(&:id)
      ordered_media_attachment_ids.filter_map { |media_attachment_id| map[media_attachment_id] }
    end.take(MEDIA_ATTACHMENTS_LIMIT)
  end
end
