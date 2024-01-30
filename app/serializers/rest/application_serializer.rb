# frozen_string_literal: true

class REST::ApplicationSerializer < REST::BaseSerializer
  attributes :name, :scopes, :redirect_uri

  attribute :id do
    application.id.to_s
  end

  attribute :client_id do
    application.uid
  end

  attribute :client_secret do
    application.secret
  end

  attribute :website do
    application.website.presence
  end

  # NOTE: Deprecated in 4.3.0, needs to be removed in 5.0.0
  attribute :vapid_key do
    Rails.configuration.x.vapid_public_key
  end
end
