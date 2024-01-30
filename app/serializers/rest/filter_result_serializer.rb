# frozen_string_literal: true

class REST::FilterResultSerializer < REST::BaseSerializer
  belongs_to :filter, serializer: REST::FilterSerializer

  attribute :status_matches do
    filter_result.status_matches&.map(&:to_s)
  end

  attribute :keyword_matches do
    filter_result.keyword_matches&.map(&:to_s)
  end
end
