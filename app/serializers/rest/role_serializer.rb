# frozen_string_literal: true

class REST::RoleSerializer < REST::BaseSerializer
  attributes :name, :color, :highlighted

  attribute :id do
    role.id.to_s
  end

  attribute :permissions do
    role.computed_permissions.to_s
  end
end
