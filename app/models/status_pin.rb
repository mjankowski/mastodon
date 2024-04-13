# frozen_string_literal: true

class StatusPin < ApplicationRecord
  belongs_to :account
  belongs_to :status

  validates_with StatusPinValidator

  after_destroy :invalidate_cleanup_info

  def invalidate_cleanup_info
    return unless status&.account_id == account_id && account.local?

    account.statuses_cleanup_policy&.invalidate_last_inspected(status, :unpin)
  end
end
