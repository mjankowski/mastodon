# frozen_string_literal: true

class REST::NotificationSerializer < REST::BaseSerializer
  attributes :type, :created_at

  belongs_to :from_account, as: :account, serializer: REST::AccountSerializer
  belongs_to :target_status, as: :status, if: :status_type?, serializer: REST::StatusSerializer
  belongs_to :report, if: :report_type?, serializer: REST::ReportSerializer

  attribute :id do
    notification.id.to_s
  end

  def status_type?
    [:favourite, :reblog, :status, :mention, :poll, :update].include?(notification.type)
  end

  def report_type?
    notification.type == :'admin.report'
  end
end
