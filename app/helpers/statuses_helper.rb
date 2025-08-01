# frozen_string_literal: true

module StatusesHelper
  VISIBLITY_ICONS = {
    public: 'globe',
    unlisted: 'lock_open',
    private: 'lock',
    direct: 'alternate_email',
  }.freeze

  def nothing_here(extra_classes = '')
    tag.div(class: ['nothing-here', extra_classes]) do
      t('accounts.nothing_here')
    end
  end

  def status_classnames(status, is_quote)
    if is_quote
      'status--is-quote'
    elsif status.quote.present?
      'status--has-quote'
    end
  end

  def status_description(status)
    StatusDescriptionPresenter.new(status).description
  end

  # This logic should be kept in sync with https://github.com/mastodon/mastodon/blob/425311e1d95c8a64ddac6c724fca247b8b893a82/app/javascript/mastodon/features/status/components/card.jsx#L160
  def preview_card_aspect_ratio_classname(preview_card)
    interactive = preview_card.type == 'video'
    large_image = (preview_card.image.present? && preview_card.width > preview_card.height) || interactive

    if large_image && interactive
      'status-card__image--video'
    elsif large_image
      'status-card__image--large'
    else
      'status-card__image--normal'
    end
  end

  def visibility_icon(status)
    VISIBLITY_ICONS[status.visibility.to_sym]
  end

  def prefers_autoplay?
    ActiveModel::Type::Boolean.new.cast(params[:autoplay]) || current_user&.setting_auto_play_gif
  end

  def render_seo_schema(status)
    json = ActiveModelSerializers::SerializableResource.new(
      status,
      serializer: SEO::SocialMediaPostingSerializer,
      adapter: SEO::Adapter
    ).to_json

    # rubocop:disable Rails/OutputSafety
    content_tag(:script, json_escape(json).html_safe, type: 'application/ld+json')
    # rubocop:enable Rails/OutputSafety
  end
end
