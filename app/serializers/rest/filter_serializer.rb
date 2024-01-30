# frozen_string_literal: true

class REST::FilterSerializer < REST::BaseSerializer
  attributes :title, :context, :expires_at, :filter_action
  has_many :keywords, serializer: REST::FilterKeywordSerializer, if: :rules_requested?
  has_many :statuses, serializer: REST::FilterStatusSerializer, if: :rules_requested?

  attribute :id do
    filter.id.to_s
  end

  def rules_requested?
    options[:rules_requested]
  end
end
