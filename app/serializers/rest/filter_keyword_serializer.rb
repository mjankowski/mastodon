# frozen_string_literal: true

class REST::FilterKeywordSerializer < REST::BaseSerializer
  attributes :keyword, :whole_word

  attribute :id do
    filter_keyword.id.to_s
  end
end
