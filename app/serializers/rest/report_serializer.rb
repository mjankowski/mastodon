# frozen_string_literal: true

class REST::ReportSerializer < REST::BaseSerializer
  attributes :action_taken, :action_taken_at, :category, :comment,
             :forwarded, :created_at

  has_one :target_account, serializer: REST::AccountSerializer

  attribute :id do
    report.id.to_s
  end

  attribute :status_ids do
    report&.status_ids&.map(&:to_s)
  end

  attribute :rule_ids do
    report&.rule_ids&.map(&:to_s)
  end
end
