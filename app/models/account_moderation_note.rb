# frozen_string_literal: true

class AccountModerationNote < ApplicationRecord
  CONTENT_SIZE_LIMIT = 2_000

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  scope :latest, -> { reorder(created_at: :desc) }

  validates :content, presence: true, length: { maximum: CONTENT_SIZE_LIMIT }
end
