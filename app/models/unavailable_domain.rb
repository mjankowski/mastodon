# frozen_string_literal: true

class UnavailableDomain < ApplicationRecord
  include DomainNormalizable

  validates :domain, presence: true, uniqueness: true

  after_commit :reset_cache!

  alias_attribute :to_log_human_identifier, :domain

  private

  def reset_cache!
    Rails.cache.delete('unavailable_domains')
  end
end
