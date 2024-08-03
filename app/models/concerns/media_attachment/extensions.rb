# frozen_string_literal: true

module MediaAttachment::Extensions
  extend ActiveSupport::Concern

  FILES = {
    audio: %w(
      3gp
      aac
      flac
      m4a
      mp3
      oga
      ogg
      opus
      wav
      wma
    ),
    image: %w(
      avif
      gif
      heic
      heif
      jpeg
      jpg
      png
      webp
    ),
    video: %w(
      m4v
      mov
      mp4
      webm
    ),
  }.freeze

  class_methods do
    def supported_file_extensions
      FILES
        .map(&:last)
        .flatten
        .sort
        .map { |extension| ".#{extension}" }
    end
  end
end
