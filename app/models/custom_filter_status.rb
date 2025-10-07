# frozen_string_literal: true

class CustomFilterStatus < ApplicationRecord
  include CustomFilterCache

  belongs_to :custom_filter
  belongs_to :status

  validates :status_id, uniqueness: { scope: :custom_filter_id }
  validate :validate_status_access, if: [:custom_filter_account, :status]

  delegate :account, to: :custom_filter, prefix: true, allow_nil: true

  private

  def validate_status_access
    errors.add(:status_id, :invalid) unless StatusPolicy.new(custom_filter_account, status).show?
  end
end
