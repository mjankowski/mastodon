# frozen_string_literal: true

class REST::Admin::IpBlockSerializer < REST::BaseSerializer
  attributes(
    :created_at,
    :expires_at,
    :comment,
    :severity
  )

  attribute :id do
    ip_block.id.to_s
  end

  attribute :ip do
    "#{ip_block.ip}/#{ip_block.ip.prefix}"
  end
end
