# frozen_string_literal: true

class InstanceModerationNote < ApplicationRecord
  include DomainNormalizable
  include DomainMaterializable

  CONTENT_SIZE_LIMIT = 2_000

  belongs_to :account
  belongs_to :instance, inverse_of: :moderation_notes, foreign_key: :domain, primary_key: :domain, optional: true

  scope :chronological, -> { reorder(id: :asc) }

  validates :content, presence: true, length: { maximum: CONTENT_SIZE_LIMIT }
  validates :domain, presence: true, domain: true
end
