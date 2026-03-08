# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id                  :bigint(8)        not null, primary key
#  display_name        :string
#  last_status_at      :datetime
#  listable            :boolean
#  max_score           :float
#  max_score_at        :datetime
#  name                :string           default(""), not null
#  requested_review_at :datetime
#  reviewed_at         :datetime
#  trendable           :boolean
#  usable              :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Tag < ApplicationRecord
  include Naming
  include Paginable
  include Reviewable

  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :statuses
  has_and_belongs_to_many :accounts
  # rubocop:enable Rails/HasAndBelongsToMany

  has_many :passive_relationships, class_name: 'TagFollow', inverse_of: :tag, dependent: :destroy
  has_many :featured_tags, dependent: :destroy, inverse_of: :tag
  has_many :followers, through: :passive_relationships, source: :account

  has_one :trend, class_name: 'TagTrend', inverse_of: :tag, dependent: :destroy

  RECENT_STATUS_LIMIT = 1000

  scope :pending_review, -> { unreviewed.where.not(requested_review_at: nil) }
  scope :usable, -> { where(usable: [true, nil]) }
  scope :not_usable, -> { where(usable: false) }
  scope :listable, -> { where(listable: [true, nil]) }
  scope :trendable, -> { Setting.trendable_by_default ? where(trendable: [true, nil]) : where(trendable: true) }
  scope :not_trendable, -> { where(trendable: false) }
  scope :suggestions_for_account, ->(account) { recently_used(account).not_featured_by(account) }
  scope :not_featured_by, ->(account) { where.not(id: account.featured_tags.select(:tag_id)) }
  scope :recently_used, lambda { |account|
                          joins(:statuses)
                            .where(statuses: { id: account.statuses.select(:id).limit(RECENT_STATUS_LIMIT) })
                            .group(:id).order(Arel.star.count.desc)
                        }

  update_index('tags', :self)

  def to_param
    name
  end

  def usable
    boolean_with_default('usable', true)
  end

  alias usable? usable

  def listable
    boolean_with_default('listable', true)
  end

  alias listable? listable

  def trendable
    boolean_with_default('trendable', Setting.trendable_by_default)
  end

  alias trendable? trendable

  def decaying?
    max_score_at && max_score_at >= Trends.tags.options[:max_score_cooldown].ago && max_score_at < 1.day.ago
  end

  def history
    @history ||= Trends::History.new('tags', id)
  end

  class << self
    def search_for(term, limit = 5, offset = 0, options = {})
      stripped_term = term.strip
      options.reverse_merge!({ exclude_unlistable: true, exclude_unreviewed: false })

      query = Tag.matches_name(stripped_term)
      query = query.merge(Tag.listable) if options[:exclude_unlistable]
      query = query.merge(matching_name(stripped_term).or(reviewed)) if options[:exclude_unreviewed]

      query.order(Arel.sql('LENGTH(name)').asc, name: :asc)
        .limit(limit)
        .offset(offset)
    end

    def find_normalized(name)
      matching_name(name).first
    end

    def find_normalized!(name)
      find_normalized(name) || raise(ActiveRecord::RecordNotFound)
    end
  end
end
