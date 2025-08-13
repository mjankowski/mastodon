# frozen_string_literal: true

# == Schema Information
#
# Table name: generated_annual_reports
#
#  id             :bigint(8)        not null, primary key
#  account_id     :bigint(8)        not null
#  year           :integer          not null
#  data           :jsonb            not null
#  schema_version :integer          not null
#  viewed_at      :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class GeneratedAnnualReport < ApplicationRecord
  belongs_to :account

  scope :pending, -> { where(viewed_at: nil) }

  store_accessor :data, %i(most_reblogged_accounts commonly_interacted_with_accounts top_statuses)

  def viewed?
    viewed_at.present?
  end

  def view!
    touch(:viewed_at)
  end

  def account_ids
    most_reblogged_accounts.pluck('account_id') + commonly_interacted_with_accounts.pluck('account_id')
  end

  def status_ids
    top_statuses.values
  end
end
