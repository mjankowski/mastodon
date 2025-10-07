# frozen_string_literal: true

class AnnouncementReaction < ApplicationRecord
  before_validation :set_custom_emoji, if: :name?
  after_commit :queue_publish

  with_options inverse_of: :announcement_reactions do
    belongs_to :account
    belongs_to :announcement
  end

  belongs_to :custom_emoji, optional: true

  validates :name, presence: true
  validates_with ReactionValidator

  scope :by_minimum_created, -> { order(arel_table[:created_at].minimum.asc) }

  private

  def set_custom_emoji
    self.custom_emoji = CustomEmoji.local.enabled.find_by(shortcode: name)
  end

  def queue_publish
    PublishAnnouncementReactionWorker.perform_async(announcement_id, name) unless announcement.destroyed?
  end
end
