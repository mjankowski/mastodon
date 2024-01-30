# frozen_string_literal: true

class REST::StatusEditSerializer < REST::BaseSerializer
  include FormattingHelper

  has_one :account, serializer: REST::AccountSerializer

  attributes :spoiler_text,
             :sensitive,
             :created_at

  has_many :ordered_media_attachments,
           as: :media_attachments,
           serializer: REST::MediaAttachmentSerializer
  has_many :emojis,
           serializer: REST::CustomEmojiSerializer

  attribute :content do
    status_content_format(status_edit)
  end

  attribute :poll, if: -> { status_edit.poll_options.present? } do
    { options: status_edit.poll_options.map { |title| { title: title } } }
  end
end
