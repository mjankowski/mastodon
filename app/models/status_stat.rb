# frozen_string_literal: true

# == Schema Information
#
# Table name: status_stats
#
#  id                         :bigint(8)        not null, primary key
#  favourites_count           :bigint(8)        default(0), not null
#  quotes_count               :bigint(8)        default(0), not null
#  reblogs_count              :bigint(8)        default(0), not null
#  replies_count              :bigint(8)        default(0), not null
#  untrusted_favourites_count :bigint(8)
#  untrusted_reblogs_count    :bigint(8)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  status_id                  :bigint(8)        not null
#

class StatusStat < ApplicationRecord
  include Counters

  belongs_to :status, inverse_of: :status_stat

  before_validation :clamp_untrusted_counts

  MAX_UNTRUSTED_COUNT = 100_000_000

  counter_columns :favourites_count, :quotes_count, :reblogs_count, :replies_count

  private

  def clamp_untrusted_counts
    self.untrusted_favourites_count = untrusted_favourites_count.to_i.clamp(0, MAX_UNTRUSTED_COUNT) if untrusted_favourites_count?
    self.untrusted_reblogs_count = untrusted_reblogs_count.to_i.clamp(0, MAX_UNTRUSTED_COUNT) if untrusted_reblogs_count?
  end
end
