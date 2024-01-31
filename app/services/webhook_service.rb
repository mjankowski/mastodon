# frozen_string_literal: true

class WebhookService < BaseService
  def call(event, object)
    @event  = Webhooks::EventPresenter.new(event, object)
    @body   = serialize_event

    webhooks_for_event.each do |webhook_id|
      Webhooks::DeliveryWorker.perform_async(webhook_id, @body)
    end
  end

  private

  def webhooks_for_event
    Webhook.enabled.where('? = ANY(events)', @event.type).pluck(:id)
  end

  def serialize_event
    # TODO: eh?
    Oj.dump(REST::Admin::WebhookEventSerializer.one(@event, current_user: nil).as_json)
  end
end
