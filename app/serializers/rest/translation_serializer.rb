# frozen_string_literal: true

class REST::TranslationSerializer < REST::BaseSerializer
  attributes :detected_source_language, :language, :provider, :spoiler_text, :content

  class PollSerializer < REST::BaseSerializer
    class OptionSerializer < REST::BaseSerializer
      attributes :title
    end

    has_many :options, serializer: OptionSerializer

    attribute :id do
      poll.status.preloadable_poll.id.to_s
    end

    def options
      poll.poll_options
    end
  end

  has_one :poll, serializer: PollSerializer

  class MediaAttachmentSerializer < REST::BaseSerializer
    attributes :description

    attribute :id do
      media_attachment.id.to_s
    end
  end

  has_many :media_attachments, serializer: MediaAttachmentSerializer

  def poll
    translation if translation.status.preloadable_poll
  end
end
