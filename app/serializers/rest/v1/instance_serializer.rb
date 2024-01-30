# frozen_string_literal: true

class REST::V1::InstanceSerializer < REST::BaseSerializer
  include RoutingHelper

  attributes :title,
             :version,
             :languages

  has_one :contact_account, serializer: REST::AccountSerializer

  has_many :rules, serializer: REST::RuleSerializer

  attribute :uri do
    instance.domain
  end

  attribute :short_description do
    instance.description
  end

  attribute :description do
    Setting.site_description # Legacy
  end

  attribute :email do
    instance.contact.email
  end

  def contact_account
    instance.contact.account
  end

  attribute :thumbnail do
    instance.thumbnail ? full_asset_url(instance.thumbnail.file.url(:'@1x')) : frontend_asset_url('images/preview.png')
  end

  attribute :stats do
    {
      user_count: instance.user_count,
      status_count: instance.status_count,
      domain_count: instance.domain_count,
    }
  end

  attribute :urls do
    { streaming_api: Rails.configuration.x.streaming_api_base_url }
  end

  def usage
    {
      users: {
        active_month: instance.active_user_count(4),
      },
    }
  end

  attribute :configuration do
    {
      accounts: {
        max_featured_tags: FeaturedTag::LIMIT,
      },

      statuses: {
        max_characters: StatusLengthValidator::MAX_CHARS,
        max_media_attachments: 4,
        characters_reserved_per_url: StatusLengthValidator::URL_PLACEHOLDER_CHARS,
      },

      media_attachments: {
        supported_mime_types: MediaAttachment::IMAGE_MIME_TYPES + MediaAttachment::VIDEO_MIME_TYPES + MediaAttachment::AUDIO_MIME_TYPES,
        image_size_limit: MediaAttachment::IMAGE_LIMIT,
        image_matrix_limit: Attachmentable::MAX_MATRIX_LIMIT,
        video_size_limit: MediaAttachment::VIDEO_LIMIT,
        video_frame_rate_limit: MediaAttachment::MAX_VIDEO_FRAME_RATE,
        video_matrix_limit: MediaAttachment::MAX_VIDEO_MATRIX_LIMIT,
      },

      polls: {
        max_options: PollValidator::MAX_OPTIONS,
        max_characters_per_option: PollValidator::MAX_OPTION_CHARS,
        min_expiration: PollValidator::MIN_EXPIRATION,
        max_expiration: PollValidator::MAX_EXPIRATION,
      },
    }
  end

  attribute :registrations do
    Setting.registrations_mode != 'none' && !Rails.configuration.x.single_user_mode
  end

  attribute :approval_required do
    Setting.registrations_mode == 'approved'
  end

  attribute :invites_enabled do
    UserRole.everyone.can?(:invite_users)
  end
end
