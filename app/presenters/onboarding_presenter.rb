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
end
