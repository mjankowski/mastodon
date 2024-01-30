# frozen_string_literal: true

class REST::Admin::EmailDomainBlockSerializer < REST::BaseSerializer
  attributes(
    :allow_with_approval,
    :created_at,
    :domain,
    :history
  )

  attribute :id do
    email_domain_block.id.to_s
  end
end
