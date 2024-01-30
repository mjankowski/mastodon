# frozen_string_literal: true

class REST::Admin::ReportSerializer < REST::BaseSerializer
  attributes(
    :created_at,
    :forwarded,
    :updated_at,
    :action_taken_at,
    :action_taken,
    :category,
    :comment
  )

  has_one :account, serializer: REST::Admin::AccountSerializer
  has_one :target_account, serializer: REST::Admin::AccountSerializer
  has_one :assigned_account, serializer: REST::Admin::AccountSerializer
  has_one :action_taken_by_account, serializer: REST::Admin::AccountSerializer

  has_many :statuses, serializer: REST::StatusSerializer
  has_many :rules, serializer: REST::RuleSerializer

  attribute :id do
    report.id.to_s
  end

  def statuses
    report.statuses.with_includes
  end
end
