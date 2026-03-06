# frozen_string_literal: true

module Status::Polls
  extend ActiveSupport::Concern

  included do
    belongs_to :preloadable_poll, class_name: 'Poll', foreign_key: 'poll_id', optional: true, inverse_of: false
    has_one :poll, inverse_of: :status, dependent: :destroy

    accepts_nested_attributes_for :poll

    scope :only_polls, -> { where.not(poll_id: nil) }
    scope :without_polls, -> { where(poll_id: nil) }

    after_create :set_poll_id

    def with_poll?
      preloadable_poll.present?
    end

    private

    def set_poll_id
      update_column(:poll_id, poll.id) if association(:poll).loaded? && poll.present?
    end
  end
end
