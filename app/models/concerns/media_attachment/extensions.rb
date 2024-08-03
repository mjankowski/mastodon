# frozen_string_literal: true

module MediaAttachment::Extensions
  extend ActiveSupport::Concern

  FILES = {
    audio: %w(ogg oga mp3 wav flac opus aac m4a 3gp wma),
    image: %w(jpg jpeg png gif webp heic heif avif),
    video: %w(webm mp4 m4v mov),
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
