# frozen_string_literal: true

class UpdateGlobalFollowRecommendationsToVersion2 < ActiveRecord::Migration[7.2]
  def change
    update_view :global_follow_recommendations,
                version: 2,
                revert_to_version: 1,
                materialized: { side_by_side: true }
  end
end
