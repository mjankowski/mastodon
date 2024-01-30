# frozen_string_literal: true

class REST::Admin::DomainBlockSerializer < REST::BaseSerializer
  attributes(
    :created_at,
    :digest,
    :domain,
    :id,
    :obfuscate,
    :private_comment,
    :public_comment,
    :reject_media,
    :reject_reports,
    :severity
  )

  attribute :id do
    domain_block.id.to_s
  end

  def digest
    object.domain_digest
  end
end
