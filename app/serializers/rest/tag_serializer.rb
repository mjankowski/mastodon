# frozen_string_literal: true

class REST::TagSerializer < REST::BaseSerializer
  include RoutingHelper

  attributes :history

  attribute :url do
    tag_url(tag)
  end

  attribute :name do
    tag.display_name
  end

  attribute :following, if: :current_user? do
    if options && options[:relationships]
      options[:relationships].following_map[tag.id] || false
    else
      TagFollow.exists?(tag_id: tag.id, account_id: current_user.account_id)
    end
  end
end
