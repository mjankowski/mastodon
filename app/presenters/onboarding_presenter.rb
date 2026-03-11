# frozen_string_literal: true

class OnboardingPresenter
  attr_reader :account

  SUGGESTION_LIMIT = 5

  def initialize(user)
    @account = user.account
  end

  def account_fields_present?
    account.display_name.present? || account.note.present? || account.avatar.present?
  end

  def active_relationships?
    account.active_relationships.exists?
  end

  def statuses_exist?
    account.statuses.exists?
  end

  def tags
    allowed_trending_tags.limit(SUGGESTION_LIMIT)
  end

  def account_suggestions
    suggestions_for_account.get(SUGGESTION_LIMIT)
  end

  private

  def allowed_trending_tags
    Trends.tags.query.allowed
  end

  def suggestions_for_account
    AccountSuggestions.new(account)
  end
end
