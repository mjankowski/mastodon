# frozen_string_literal: true

class REST::V1::FilterSerializer < REST::BaseSerializer
  attributes :whole_word

  attribute :context do
    custom_filter.context
  end

  attribute :expires_at do
    custom_filter.expires_at
  end

  attribute :id do
    filter.id.to_s
  end

  attribute :phrase do
    filter.keyword
  end

  attribute :irreversible do
    custom_filter.irreversible?
  end

  private

  def custom_filter
    filter.custom_filter
  end
end
