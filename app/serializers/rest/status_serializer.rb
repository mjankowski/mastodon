# frozen_string_literal: true

class REST::StatusSerializer < REST::BaseSerializer
  include FormattingHelper

  class ApplicationSerializer < REST::BaseSerializer
    attributes :name

    attribute :website do
      application.website.presence
    end
  end

  class MentionSerializer < REST::BaseSerializer
    attribute :id do
      mention.account_id.to_s
    end

    attribute :username do
      mention.account_username
    end

    attribute :url do
      ActivityPub::TagManager.instance.url_for(mention.account)
    end

    attribute :acct do
      mention.account.pretty_acct
    end
  end

  class TagSerializer < REST::BaseSerializer
    include RoutingHelper

    attributes :name

    attribute :url do
      tag_url(tag)
    end
  end

  attributes :created_at,
             :spoiler_text, :language,
             :replies_count, :edited_at

  has_many :filtered, serializer: REST::FilterResultSerializer, if: :current_user?

  attributes :text, if: :source_requested?

  attribute :reblog, if: -> { status.reblog? } do
    # TODO: needs to pass in current_user from options, which cant happen via a belongs_to approach?
    REST::StatusSerializer.one(status.reblog, current_user: current_user)
  end

  belongs_to :application, if: :show_application?, serializer: ApplicationSerializer
  belongs_to :account, serializer: REST::AccountSerializer

  has_many :ordered_media_attachments, as: :media_attachments, serializer: REST::MediaAttachmentSerializer
  has_many :ordered_mentions, as: :mentions, serializer: MentionSerializer
  has_many :tags, serializer: TagSerializer
  has_many :emojis, serializer: REST::CustomEmojiSerializer

  has_one :preview_card, as: :card, serializer: REST::PreviewCardSerializer
  # has_one :preloadable_poll, as: :poll, serializer: REST::PollSerializer

  attribute :id do
    status.id.to_s
  end

  attribute :in_reply_to_id do
    status.in_reply_to_id&.to_s
  end

  attribute :in_reply_to_account_id do
    status.in_reply_to_account_id&.to_s
  end

  def show_application?
    status.account.user_shows_application? || (current_user? && current_user.account_id == status.account_id)
  end

  attribute :visibility do
    # This visibility is masked behind "private"
    # to avoid API changes because there are no
    # UX differences
    if status.limited_visibility?
      'private'
    else
      status.visibility
    end
  end

  attribute :sensitive do
    if current_user? && current_user.account_id == status.account_id
      status.sensitive
    else
      status.account.sensitized? || status.sensitive
    end
  end

  attribute :uri do
    ActivityPub::TagManager.instance.uri_for(status)
  end

  attribute :content, if: -> { !source_requested? } do
    status_content_format(status)
  end

  attribute :url do
    ActivityPub::TagManager.instance.url_for(status)
  end

  attribute :reblogs_count do
    relationships&.attributes_map&.dig(status.id, :reblogs_count) || status.reblogs_count
  end

  attribute :favourites_count do
    relationships&.attributes_map&.dig(status.id, :favourites_count) || status.favourites_count
  end

  attribute :favourited, if: :current_user? do
    if relationships
      relationships.favourites_map[status.id] || false
    else
      current_user.account.favourited?(status)
    end
  end

  attribute :reblogged, if: :current_user? do
    if relationships
      relationships.reblogs_map[status.id] || false
    else
      current_user.account.reblogged?(status)
    end
  end

  attribute :muted, if: :current_user? do
    if relationships
      relationships.mutes_map[status.conversation_id] || false
    else
      current_user.account.muting_conversation?(status.conversation)
    end
  end

  attribute :bookmarked, if: :current_user? do
    if relationships
      relationships.bookmarks_map[status.id] || false
    else
      current_user.account.bookmarked?(status)
    end
  end

  attribute :pinned, if: :pinnable? do
    if relationships
      relationships.pins_map[status.id] || false
    else
      current_user.account.pinned?(status)
    end
  end

  def filtered
    if relationships
      relationships.filters_map[status.id] || []
    else
      current_user.account.status_matches_filters(status)
    end
  end

  def pinnable?
    current_user? &&
      current_user.account_id == status.account_id &&
      !status.reblog? &&
      %w(public unlisted private).include?(status.visibility)
  end

  def source_requested?
    options[:source_requested]
  end

  def ordered_mentions
    status.active_mentions.to_a.sort_by(&:id)
  end

  private

  def relationships
    options && options[:relationships]
  end
end
