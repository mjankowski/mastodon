# frozen_string_literal: true

class REST::Admin::DomainAllowSerializer < REST::BaseSerializer
  attributes(
    :created_at,
    :domain
  )

  attribute :id do
    domain_allow.id.to_s
  end
end
