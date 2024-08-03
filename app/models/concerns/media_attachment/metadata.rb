# frozen_string_literal: true

module MediaAttachment::Metadata
  extend ActiveSupport::Concern

  META_KEYS = %i(
    colors
    focus
    original
    small
  ).freeze

  included do
    after_post_process :set_meta
  end

  def set_meta
    file.instance_write :meta, populate_meta
  end

  def populate_meta
    meta_attribute.tap do |meta|
      file.queued_for_write.each do |style, file|
        meta[style] = style == :small || image? ? image_geometry(file) : video_metadata(file)
      end

      meta[:small] = image_geometry(thumbnail.queued_for_write[:original]) if thumbnail.queued_for_write.key?(:original)
    end
  end

  def image_geometry(file)
    width, height = FastImage.size(file.path)

    return {} if width.nil?

    {
      width: width,
      height: height,
      size: "#{width}x#{height}",
      aspect: width.to_f / height,
    }
  end

  def video_metadata(file)
    movie = ffmpeg_data(file.path)

    return {} unless movie.valid?

    {
      width: movie.width,
      height: movie.height,
      frame_rate: movie.frame_rate,
      duration: movie.duration,
      bitrate: movie.bitrate,
    }.compact
  end

  private

  def meta_attribute
    (file.instance_read(:meta) || {})
      .with_indifferent_access
      .slice(*META_KEYS)
  end
end
