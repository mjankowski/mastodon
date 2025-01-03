# frozen_string_literal: true

class UpdateGlobalFollowRecommendationsToVersion3 < ActiveRecord::Migration[7.2]
  def change
    update_view :global_follow_recommendations,
                version: 3,
                revert_to_version: 2,
                materialized: { side_by_side: true }
  end
end
