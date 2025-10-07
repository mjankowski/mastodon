# frozen_string_literal: true

class Announcement < ApplicationRecord
  scope :unpublished, -> { where(published: false) }
  scope :published, -> { where(published: true) }
  scope :chronological, -> { order(coalesced_chronology_timestamps.asc) }
  scope :reverse_chronological, -> { order(coalesced_chronology_timestamps.desc) }

  with_options dependent: :destroy, inverse_of: :announcement do
    has_many :announcement_mutes
    has_many :announcement_reactions
  end

  validates :text, presence: true
  validates :starts_at, presence: true, if: :ends_at?
  validates :ends_at, presence: true, if: :starts_at?

  before_validation :set_published, on: :create

  alias_attribute :to_log_human_identifier, :text

  class << self
    def coalesced_chronology_timestamps
      arel_table.coalesce(arel_table[:starts_at], arel_table[:scheduled_at], arel_table[:published_at], arel_table[:created_at])
    end
  end

  def publish!
    update!(published: true, published_at: Time.now.utc, scheduled_at: nil)
  end

  def unpublish!
    update!(published: false, scheduled_at: nil)
  end

  def notification_sent?
    notification_sent_at?
  end

  def mentions
    @mentions ||= Account.from_text(text)
  end

  def statuses
    @statuses ||= begin
      if status_ids.nil?
        []
      else
        Status.with_includes.distributable_visibility.where(id: status_ids)
      end
    end
  end

  def tags
    @tags ||= Tag.find_or_create_by_names(Extractor.extract_hashtags(text))
  end

  def emojis
    @emojis ||= CustomEmoji.from_text(text)
  end

  def reactions(account = nil)
    grouped_ordered_announcement_reactions.select(
      [:name, :custom_emoji_id, Arel.star.count.as('count')].tap do |values|
        values << value_for_reaction_me_column(account).as('me')
      end
    ).to_a.tap do |records|
      ActiveRecord::Associations::Preloader.new(records: records, associations: :custom_emoji).call
    end
  end

  def scope_for_notification
    User.confirmed.joins(:account).merge(Account.without_suspended)
  end

  private

  def grouped_ordered_announcement_reactions
    announcement_reactions
      .group(:announcement_id, :name, :custom_emoji_id)
      .by_minimum_created
  end

  def value_for_reaction_me_column(account)
    if account.nil?
      self.class.arel_table.create_false
    else
      Arel.sql(<<~SQL.squish)
        EXISTS(
          SELECT 1
          FROM announcement_reactions inner_reactions
          WHERE inner_reactions.account_id = #{account.id}
            AND inner_reactions.announcement_id = announcement_reactions.announcement_id
            AND inner_reactions.name = announcement_reactions.name
        )
      SQL
    end
  end

  def set_published
    return unless scheduled_at.blank? || scheduled_at.past?

    self.published = true
    self.published_at = Time.now.utc
  end
end
