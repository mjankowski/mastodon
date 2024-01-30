# frozen_string_literal: true

class REST::StatusSourceSerializer < REST::BaseSerializer
  attributes :text, :spoiler_text

  attribute :id do
    status_source.id.to_s
  end
end
