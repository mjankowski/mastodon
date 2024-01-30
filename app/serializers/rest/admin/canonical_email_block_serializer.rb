# frozen_string_literal: true

class REST::Admin::CanonicalEmailBlockSerializer < REST::BaseSerializer
  attributes :canonical_email_hash

  attribute :id do
    canonical_email_block.id.to_s
  end
end
