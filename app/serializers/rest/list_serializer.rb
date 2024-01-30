# frozen_string_literal: true

class REST::ListSerializer < REST::BaseSerializer
  attributes :title, :replies_policy, :exclusive

  attribute :id do
    list.id.to_s
  end
end
