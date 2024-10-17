# frozen_string_literal: true

class OnboardingPresenter
  attr_reader :account

  SUGGESTED_ACCOUNTS = 5
  SUGGESTED_TAGS = 5

  def initialize(account)
    @account = account
  end

  def suggestions
    AccountSuggestions
      .new(account)
      .get(SUGGESTED_ACCOUNTS)
  end

  def tags
    Trends
      .tags
      .query
      .allowed
      .limit(SUGGESTED_TAGS)
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
end
