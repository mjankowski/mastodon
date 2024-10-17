# frozen_string_literal: true

class OnboardingPresenter
  attr_reader :account

  def initialize(account)
    @account = account
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
