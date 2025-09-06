# frozen_string_literal: true

# See also: USERNAME_RE in the Account class

class UniqueUsernameValidator < ActiveModel::Validator
  def validate(account)
    return if account.username.blank?

    account.errors.add(:username, :taken) if duplicate_username(account).exists?
  end

  private

  def duplicate_username(account)
    Account.with_username(account.username).with_domain(account.domain).tap do |scope|
      scope.merge! scope.excluding(account) if account.persisted?
    end
  end
end
