# frozen_string_literal: true

class AnnouncementMute < ApplicationRecord
  with_options inverse_of: :announcement_mutes do
    belongs_to :account
    belongs_to :announcement
  end

  validates :account_id, uniqueness: { scope: :announcement_id }
end
