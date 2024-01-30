# frozen_string_literal: true

class REST::ScheduledStatusSerializer < REST::BaseSerializer
  attributes :scheduled_at

  has_many :media_attachments, serializer: REST::MediaAttachmentSerializer

  attribute :id do
    scheduled_status.id.to_s
  end

  attribute :params do
    scheduled_status.params.without(:application_id)
  end
end
