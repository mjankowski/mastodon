# frozen_string_literal: true

class UpdateGlobalFollowRecommendationsToVersion4 < ActiveRecord::Migration[7.2]
  def change
    update_view :global_follow_recommendations,
                version: 4,
                revert_to_version: 3,
                materialized: { side_by_side: true }
  end
end
