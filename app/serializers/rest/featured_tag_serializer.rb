# frozen_string_literal: true

class REST::FeaturedTagSerializer < REST::BaseSerializer
  include RoutingHelper

  attribute :id do
    featured_tag.id.to_s
  end

  attribute :url do
    # The path is hardcoded because we have to deal with both local and
    # remote users, which are different routes
    account_with_domain_url(featured_tag.account, "tagged/#{featured_tag.tag.to_param}")
  end

  attribute :name do
    featured_tag.display_name
  end

  attribute :statuses_count do
    featured_tag.statuses_count.to_s
  end

  attribute :last_status_at do
    featured_tag.last_status_at&.to_date&.iso8601
  end
end
