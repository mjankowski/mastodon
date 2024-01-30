# frozen_string_literal: true

class REST::RuleSerializer < REST::BaseSerializer
  attributes :text, :hint

  attribute :id do
    rule.id.to_s
  end
end
