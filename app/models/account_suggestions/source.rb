# frozen_string_literal: true

class AccountSuggestions::Source
  DEFAULT_LIMIT = 10

  def get(_account, **kwargs)
    raise NotImplementedError
  end

  protected

  def base_account_scope(account)
    Account
      .searchable
      .where(discoverable: true)
      .without_silenced
      .without_memorial
      .where.not(targeted_for(Follow, account))
      .where.not(targeted_for(FollowRequest, account))
      .not_excluded_by_account(account)
      .not_domain_blocked_by_account(account)
      .where.not(id: account.id)
      .where.not(targeted_for(FollowRecommendationMute, account))
  end

  def targeted_for(klass, account)
    klass
      .where(klass.arel_table[:target_account_id].eq Account.arel_table[:id])
      .where(account: account)
      .select(1)
      .arel
      .exists
  end
end
