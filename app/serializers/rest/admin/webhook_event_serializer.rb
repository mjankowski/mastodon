# frozen_string_literal: true

class REST::Admin::WebhookEventSerializer < REST::BaseSerializer
  def self.serializer_for(model, options)
    case model.class.name
    when 'Account'
      REST::Admin::AccountSerializer
    when 'Report'
      REST::Admin::ReportSerializer
    when 'Status'
      REST::StatusSerializer
    else
      super
    end
  end

  attributes :created_at

  attribute :object do
    webhook_event.object
  end

  attribute :event do
    webhook_event.type
  end
end
