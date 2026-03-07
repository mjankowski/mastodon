# frozen_string_literal: true

module MediaAttachment::MimeTypes
  extend ActiveSupport::Concern

  IMAGE_MIME_TYPES             = %w(image/jpeg image/png image/gif image/heic image/heif image/webp image/avif).freeze
  IMAGE_CONVERTIBLE_MIME_TYPES = %w(image/heic image/heif image/avif).freeze
  VIDEO_MIME_TYPES             = %w(video/webm video/mp4 video/quicktime video/ogg).freeze
  VIDEO_CONVERTIBLE_MIME_TYPES = %w(video/webm video/quicktime).freeze
  AUDIO_MIME_TYPES             = %w(audio/wave audio/wav audio/x-wav audio/x-pn-wave audio/vnd.wave audio/ogg audio/vorbis audio/mpeg audio/mp3 audio/webm audio/flac audio/aac audio/m4a audio/x-m4a audio/mp4 audio/3gpp video/x-ms-asf).freeze

  class_methods do
    def supported_mime_types
      IMAGE_MIME_TYPES + VIDEO_MIME_TYPES + AUDIO_MIME_TYPES
    end
  end

  private

  def set_type_and_extension
    self.type = begin
      if VIDEO_MIME_TYPES.include?(file_content_type)
        :video
      elsif AUDIO_MIME_TYPES.include?(file_content_type)
        :audio
      else
        :image
      end
    end
  end
end
