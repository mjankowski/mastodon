# frozen_string_literal: true

class REST::FamiliarFollowersSerializer < REST::BaseSerializer
  has_many :accounts, serializer: REST::AccountSerializer

  attribute :id do
    familiar_followers.id.to_s
  end
end
