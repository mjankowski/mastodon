# frozen_string_literal: true

class AccountWarningPreset < ApplicationRecord
  LABEL_TEXT_LENGTH = 30

  validates :text, presence: true

  scope :alphabetic, -> { order(title: :asc, text: :asc) }

  def to_label
    [title.presence, text.to_s.truncate(LABEL_TEXT_LENGTH)]
      .compact
      .join(' - ')
  end
end
