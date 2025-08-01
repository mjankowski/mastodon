# frozen_string_literal: true

class StatusDescriptionPresenter
  JOIN = ' · '

  attr_reader :status

  def initialize(status)
    @status = status
  end

  def description
    relevant_componenents
      .compact_blank
      .join("\n\n")
  end

  private

  def relevant_componenents
    [default_description].tap do |components|
      unless status.spoiler_text?
        components << status.text
        components << poll_summary
      end
    end
  end

  def default_description
    [media_summary, spoiler_warning]
      .compact_blank
      .join(JOIN)
  end

  def media_summary
    return if media_attachment_text.blank?

    I18n.t('statuses.attached.description', attached: media_attachment_text)
  end

  def media_attachment_text
    media_attachment_counts
      .reject { |_, value| value.zero? }
      .map { |key, value| I18n.t("statuses.attached.#{key}", count: value) }
      .join(JOIN)
  end

  def media_attachment_counts
    { image: 0, video: 0, audio: 0 }.tap do |attachments|
      status.ordered_media_attachments.each do |media|
        if media.video?
          attachments[:video] += 1
        elsif media.audio?
          attachments[:audio] += 1
        else
          attachments[:image] += 1
        end
      end
    end
  end

  def spoiler_warning
    return unless status.spoiler_text?

    I18n.t('statuses.content_warning', warning: status.spoiler_text)
  end

  def poll_summary
    return unless status.preloadable_poll

    status
      .preloadable_poll
      .options
      .map { |option| "[ ] #{option}" }
      .join("\n")
  end
end
