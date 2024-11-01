# frozen_string_literal: true

class FamiliarFollowersPresenter
  class Result < ActiveModelSerializers::Model
    attributes :id, :accounts
  end

  def initialize(accounts, current_account_id)
    @accounts           = accounts
    @current_account_id = current_account_id
  end

  def accounts
    map = Follow
          .includes(account: :account_stat)
          .where(target_account_id: @accounts.map(&:id))
          .where(account_id: follow_target_accounts)
          .group_by(&:target_account_id)
    @accounts.map { |account| Result.new(id: account.id, accounts: (account.hide_collections? ? [] : (map[account.id] || [])).map(&:account)) }
  end

  def follow_target_accounts
    Follow
      .where(account_id: @current_account_id)
      .joins(:target_account)
      .merge(Account.where(hide_collections: [nil, false]))
      .select(:target_account_id)
  end
end
