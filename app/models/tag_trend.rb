# frozen_string_literal: true

class TagTrend < ApplicationRecord
  include RankedTrend

  belongs_to :tag

  scope :allowed, -> { where(allowed: true) }
  scope :not_allowed, -> { where(allowed: false) }
end
