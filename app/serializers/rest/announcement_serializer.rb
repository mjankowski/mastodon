# frozen_string_literal: true

class REST::AnnouncementSerializer < REST::BaseSerializer
  include FormattingHelper

  attributes(
    :all_day,
    :ends_at,
    :starts_at,
    :published_at,
    :updated_at
  )

  class AccountSerializer < REST::BaseSerializer
    attributes :id, :username, :url, :acct

    def id
      account.id.to_s
    end

    def url
      ActivityPub::TagManager.instance.url_for(account)
    end

    def acct
      account.pretty_acct
    end
  end

  class StatusSerializer < REST::BaseSerializer
    attributes :id, :url

    def id
      status.id.to_s
    end

    def url
      ActivityPub::TagManager.instance.url_for(status)
    end
  end

  has_many :mentions, serializer: AccountSerializer
  has_many :statuses, serializer: StatusSerializer
  has_many :tags, serializer: REST::StatusSerializer::TagSerializer
  has_many :emojis, serializer: REST::CustomEmojiSerializer
  has_many :reactions, serializer: REST::ReactionSerializer

  attribute :id do
    announcement.id.to_s
  end

  attribute :read, if: :current_user? do
    announcement.announcement_mutes.exists?(account: current_user.account)
  end

  attribute :content do
    linkify(announcement.text)
  end

  def reactions
    announcement.reactions(current_user&.account)
  end
end
