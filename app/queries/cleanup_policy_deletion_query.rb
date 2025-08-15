# frozen_string_literal: true

class CleanupPolicyDeletionQuery
  attr_reader :policy, :min_id, :max_id

  def initialize(policy:, min_id:, max_id:)
    @policy = policy
    @min_id = min_id
    @max_id = max_id
  end

  def query
    policy.account.statuses.tap do |scope|
      scope.merge! old_enough_scope(max_id)
      scope.merge! scope.where(id: min_id..) if min_id.present?
      scope.merge! without_popular_scope if policy.min_favs? || policy.min_reblogs?
      scope.merge! without_direct_scope if policy.keep_direct?
      scope.merge! without_pinned_scope if policy.keep_pinned?
      scope.merge! without_poll_scope if policy.keep_polls?
      scope.merge! without_media_scope if policy.keep_media?
      scope.merge! without_self_fav_scope if policy.keep_self_fav?
      scope.merge! without_self_bookmark_scope if policy.keep_self_bookmark?
    end
  end

  private

  def old_enough_scope(max_id = nil)
    # Filtering on `id` over `min_status_age` treats non-snowflake statuses as
    # older than they are, but the snowflake ID migration should be completed
    snowflake_id = Mastodon::Snowflake.id_at(policy.min_status_age.seconds.ago, with_random: false)

    max_id = snowflake_id if max_id.nil? || snowflake_id < max_id

    Status.where(id: ..max_id)
  end

  def without_popular_scope
    Status.left_joins(:status_stat).tap do |scope|
      scope.merge! scope.where('COALESCE(status_stats.reblogs_count, 0) < ?', policy.min_reblogs) if policy.min_reblogs?
      scope.merge! scope.where('COALESCE(status_stats.favourites_count, 0) < ?', policy.min_favs) if policy.min_favs?
    end
  end

  def without_direct_scope
    Status.not_direct_visibility
  end

  def without_pinned_scope
    Status.where.not(self_status_reference_exists(StatusPin))
  end

  def without_poll_scope
    Status.without_polls
  end

  def without_media_scope
    Status.where.not(status_media_reference_exists)
  end

  def without_self_fav_scope
    Status.where.not(self_status_reference_exists(Favourite))
  end

  def without_self_bookmark_scope
    Status.where.not(self_status_reference_exists(Bookmark))
  end

  def status_media_reference_exists
    MediaAttachment
      .where(MediaAttachment.arel_table[:status_id].eq Status.arel_table[:id])
      .select(1)
      .arel
      .exists
  end

  def self_status_reference_exists(model)
    model
      .where(model.arel_table[:account_id].eq Status.arel_table[:account_id])
      .where(model.arel_table[:status_id].eq Status.arel_table[:id])
      .select(1)
      .arel
      .exists
  end
end
