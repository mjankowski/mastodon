# frozen_string_literal: true

class REST::PreferencesSerializer < REST::BaseSerializer
  object_as :account

  transform_keys ->(key) { "'#{key}'" } # TODO: refactor to do full conv

  attribute :posting_default_privacy, as: 'posting:default:visibility' do
    account.user.setting_default_privacy
  end

  attribute :posting_default_sensitive, as: 'posting:default:sensitive' do
    account.user.setting_default_sensitive
  end

  attribute :posting_default_language, as: 'posting:default:language' do
    account.user.preferred_posting_language
  end

  attribute :reading_default_sensitive_media, as: 'reading:expand:media' do
    account.user.setting_display_media
  end

  attribute :reading_default_sensitive_text, as: 'reading:expand:spoilers' do
    account.user.setting_expand_spoilers
  end

  attribute :reading_autoplay_gifs, as: 'reading:autoplay:gifs' do
    account.user.setting_auto_play_gif
  end
end
