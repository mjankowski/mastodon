# frozen_string_literal: true

class AnnouncementReactionQuery
  attr_reader :announcement_reactions, :account

  def initialize(announcement_reactions, account: nil)
    @announcement_reactions = announcement_reactions
    @account = account
  end

  def results
    selected_announcement_reactions.tap do |records|
      ActiveRecord::Associations::Preloader.new(
        records: records,
        associations: :custom_emoji
      ).call
    end
  end

  private

  def selected_announcement_reactions
    announcement_reactions
      .group(:announcement_id, :name, :custom_emoji_id)
      .order(AnnouncementReaction.arel_table[:created_at].minimum)
      .select(relevant_columns)
  end

  def relevant_columns
    [
      :name,
      :custom_emoji_id,
      Arel.star.count.as('count'),
      account_reacted_value.as('me'),
    ]
  end

  def account_reacted_value
    if @account.nil?
      Arel.sql(
        false.to_s.upcase
      )
    else
      account_reactions
        .select(1)
        .arel
        .exists
    end
  end

  def account_reactions
    AnnouncementReaction
      .from('announcement_reactions inner_reactions')
      .where(<<~SQL.squish)
        inner_reactions.account_id = #{@account.id}
          AND inner_reactions.announcement_id = announcement_reactions.announcement_id
          AND inner_reactions.name = announcement_reactions.name
      SQL
  end
end
