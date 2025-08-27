# frozen_string_literal: true

module MediaPlayerHelper
  PLAYER_HEIGHT = 380
  PLAYER_WIDTH = 670

  def player_component_video(media, &block)
    meta = media.file.meta || {}

    react_component(
      :video,
      alt: media.description,
      blurhash: media.blurhash,
      detailed: true,
      editable: true,
      frameRate: meta.dig('original', 'frame_rate'),
      height: PLAYER_HEIGHT,
      inline: true,
      media: serialized_media(media),
      preview: media.thumbnail.present? ? media.thumbnail.url : media.file.url(:small),
      src: media.file.url(:original),
      width: PLAYER_WIDTH,
      &block
    )
  end

  def player_component_gifv(media, &block)
    react_component(
      :media_gallery,
      autoplay: true,
      height: PLAYER_HEIGHT,
      media: serialized_media(media),
      standalone: true,
      &block
    )
  end

  def player_component_audio(media, &block)
    meta = media.file.meta || {}

    react_component(
      :audio,
      accentColor: meta.dig('colors', 'accent'),
      alt: media.description,
      backgroundColor: meta.dig('colors', 'background'),
      duration: meta.dig(:original, :duration),
      foregroundColor: meta.dig('colors', 'foreground'),
      fullscreen: true,
      height: PLAYER_HEIGHT,
      poster: media.thumbnail.present? ? media.thumbnail.url : media.account.avatar_static_url,
      src: media.file.url(:original),
      width: PLAYER_WIDTH,
      &block
    )
  end

  private

  def serialized_media(media)
    [ActiveModelSerializers::SerializableResource.new(media, serializer: REST::MediaAttachmentSerializer)].as_json
  end
end
