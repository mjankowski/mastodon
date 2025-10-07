# frozen_string_literal: true

class Fasp::Subscription < ApplicationRecord
  TYPES = %w(lifecycle trends).freeze

  belongs_to :fasp_provider, class_name: 'Fasp::Provider'

  validates :category, presence: true, inclusion: Fasp::DATA_CATEGORIES
  validates :subscription_type, presence: true,
                                inclusion: TYPES

  scope :category_content, -> { where(category: 'content') }
  scope :category_account, -> { where(category: 'account') }
  scope :lifecycle, -> { where(subscription_type: 'lifecycle') }
  scope :trends, -> { where(subscription_type: 'trends') }

  def threshold=(threshold)
    self.threshold_timeframe = threshold['timeframe'] || 15
    self.threshold_shares    = threshold['shares'] || 3
    self.threshold_likes     = threshold['likes'] || 3
    self.threshold_replies   = threshold['replies'] || 3
  end

  def timeframe_start
    threshold_timeframe.minutes.ago
  end
end
