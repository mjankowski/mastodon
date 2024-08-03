# frozen_string_literal: true

module MediaAttachment::Extensions
  extend ActiveSupport::Concern

  IMAGE_FILE_EXTENSIONS = %w(.jpg .jpeg .png .gif .webp .heic .heif .avif).freeze
  VIDEO_FILE_EXTENSIONS = %w(.webm .mp4 .m4v .mov).freeze
  AUDIO_FILE_EXTENSIONS = %w(.ogg .oga .mp3 .wav .flac .opus .aac .m4a .3gp .wma).freeze

  class_methods do
    def supported_file_extensions
      IMAGE_FILE_EXTENSIONS + VIDEO_FILE_EXTENSIONS + AUDIO_FILE_EXTENSIONS
    end
  end
end
