# frozen_string_literal: true

class REST::DomainBlockSerializer < REST::BaseSerializer
  attributes :severity

  attribute :domain do
    domain_block.public_domain
  end

  attribute :digest do
    domain_block.domain_digest
  end

  attribute :comment do
    domain_block.public_comment if options[:with_comment]
  end
end
