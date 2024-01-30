# frozen_string_literal: true

class REST::Admin::ExistingDomainBlockErrorSerializer < REST::BaseSerializer
  has_one :existing_domain_block, serializer: REST::Admin::DomainBlockSerializer

  object_as :existing_domain_block

  attribute :error do
    I18n.t('admin.domain_blocks.existing_domain_block', name: existing_domain_block.domain)
  end
end
