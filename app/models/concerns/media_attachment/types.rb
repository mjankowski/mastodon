# frozen_string_literal: true

module MediaAttachment::Types
  extend ActiveSupport::Concern

  IMAGE_MIME_TYPES = %w(
    image/avif
    image/gif
    image/heic
    image/heif
    image/jpeg
    image/png
    image/webp
  ).freeze
  IMAGE_CONVERTIBLE_MIME_TYPES = %w(
    image/avif
    image/heic
    image/heif
  ).freeze
  VIDEO_MIME_TYPES = %w(
    video/mp4
    video/ogg
    video/quicktime
    video/webm
  ).freeze
  VIDEO_CONVERTIBLE_MIME_TYPES = %w(
    video/quicktime
    video/webm
  ).freeze
  AUDIO_MIME_TYPES = %w(
    audio/3gpp
    audio/aac
    audio/flac
    audio/m4a
    audio/mp3
    audio/mp4
    audio/mpeg
    audio/ogg
    audio/vnd.wave
    audio/vorbis
    audio/wav
    audio/wave
    audio/webm
    audio/x-m4a
    audio/x-pn-wave
    audio/x-wav
    video/x-ms-asf
  ).freeze

  included do
    before_create :set_unknown_type
    before_file_validate :set_type_and_extension
  end

  class_methods do
    def supported_mime_types
      [IMAGE_MIME_TYPES, VIDEO_MIME_TYPES, AUDIO_MIME_TYPES]
        .flatten
        .sort
    end
  end

  private

  def set_unknown_type
    self.type = :unknown if file.blank? && !type_changed?
  end

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
