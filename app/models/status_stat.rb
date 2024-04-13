# frozen_string_literal: true

class StatusStat < ApplicationRecord
  belongs_to :status, inverse_of: :status_stat

  def replies_count
    [attributes['replies_count'], 0].max
  end

  def reblogs_count
    [attributes['reblogs_count'], 0].max
  end

  def favourites_count
    [attributes['favourites_count'], 0].max
  end
end
