# frozen_string_literal: true

class REST::AccountSerializer < REST::BaseSerializer
  include RoutingHelper
  include FormattingHelper

  # Please update `app/javascript/mastodon/api_types/accounts.ts` when making changes to the attributes

  attributes(
    :followers_count,
    :following_count,
    :group,
    :hide_collections,
    :statuses_count,
    :username
  )

  has_one :moved_to_account,
          as: :moved,
          serializer: REST::AccountSerializer,
          if: :moved_and_not_nested?

  has_many :emojis,
           serializer: REST::CustomEmojiSerializer

  class AccountDecorator < SimpleDelegator
    def self.model_name
      Account.model_name
    end

    def moved?
      false
    end
  end

  class RoleSerializer < REST::BaseSerializer
    attributes :name, :color

    attribute :id do
      role.id.to_s
    end
  end

  has_many :roles,
           serializer: RoleSerializer,
           if: :local?

  class FieldSerializer < REST::BaseSerializer
    include FormattingHelper

    attributes :name, :verified_at

    attribute :value do
      account_field_value_format(field)
    end
  end

  has_many :fields, serializer: FieldSerializer

  attribute :id do
    account.id.to_s
  end

  attribute :acct do
    account.pretty_acct
  end

  attribute :note do
    account.unavailable? ? '' : account_bio_format(account)
  end

  attribute :url do
    ActivityPub::TagManager.instance.url_for(account)
  end

  attribute :uri do
    ActivityPub::TagManager.instance.uri_for(account)
  end

  attribute :avatar do
    full_asset_url(account.unavailable? ? account.avatar.default_url : account.avatar_original_url)
  end

  attribute :avatar_static do
    full_asset_url(account.unavailable? ? account.avatar.default_url : account.avatar_static_url)
  end

  attribute :header do
    full_asset_url(account.unavailable? ? account.header.default_url : account.header_original_url)
  end

  attribute :header_static do
    full_asset_url(account.unavailable? ? account.header.default_url : account.header_static_url)
  end

  attribute :created_at do
    account.created_at.midnight.as_json
  end

  attribute :last_status_at do
    account.last_status_at&.to_date&.iso8601
  end

  attribute :display_name do
    account.unavailable? ? '' : account.display_name
  end

  attribute :locked do
    account.unavailable? ? false : account.locked
  end

  attribute :bot do
    account.unavailable? ? false : account.bot
  end

  attribute :discoverable do
    account.unavailable? ? false : account.discoverable
  end

  attribute :indexable do
    account.unavailable? ? false : account.indexable
  end

  attribute :suspended, if: :suspended? do
    account.unavailable?
  end

  attribute :silenced, as: :limited, if: :silenced? do
    account.silenced?
  end

  attribute :memorial, if: :memorial? do
    account.memorial?
  end

  attribute :noindex, if: :local? do
    account.user_prefers_noindex?
  end

  def moved_to_account
    account.unavailable? ? nil : AccountDecorator.new(account.moved_to_account)
  end

  def emojis
    account.unavailable? ? [] : account.emojis
  end

  def fields
    account.unavailable? ? [] : account.fields
  end

  def roles
    if account.unavailable? || account.user.nil?
      []
    else
      [account.user.role].compact.filter(&:highlighted?)
    end
  end

  def moved_and_not_nested?
    account.moved?
  end

  delegate :suspended?, :silenced?, :local?, :memorial?, to: :account
end
