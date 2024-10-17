# frozen_string_literal: true

class OnboardingPresenter
  attr_reader :account

  ACCOUNT_SUGGESTIONS = 5

  def initialize(account)
    @account = account
  end

  def suggestions
    AccountSuggestions
      .new(account)
      .get(ACCOUNT_SUGGESTIONS)
  end
end
