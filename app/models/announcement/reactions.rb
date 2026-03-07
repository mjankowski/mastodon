# frozen_string_literal: true

module Announcement::Reactions
  extend ActiveSupport::Concern

  included do
    has_many :announcement_reactions, dependent: :destroy
  end

  def reactions(account = nil)
    grouped_ordered_announcement_reactions.select(
      [:name, :custom_emoji_id, 'COUNT(*) as count'].tap do |values|
        values << value_for_reaction_me_column(account)
      end
    ).to_a.tap do |records|
      ActiveRecord::Associations::Preloader.new(records: records, associations: :custom_emoji).call
    end
  end

  private

  def grouped_ordered_announcement_reactions
    announcement_reactions
      .group(:announcement_id, :name, :custom_emoji_id)
      .order(
        Arel.sql('MIN(created_at)').asc
      )
  end

  def value_for_reaction_me_column(account)
    if account.nil?
      'FALSE AS me'
    else
      <<~SQL.squish
        EXISTS(
          SELECT 1
          FROM announcement_reactions inner_reactions
          WHERE inner_reactions.account_id = #{account.id}
            AND inner_reactions.announcement_id = announcement_reactions.announcement_id
            AND inner_reactions.name = announcement_reactions.name
        ) AS me
      SQL
    end
  end
end
