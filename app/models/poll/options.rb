# frozen_string_literal: true

module Poll::Options
  extend ActiveSupport::Concern

  included do
    validates :options, presence: true

    with_options if: :local? do
      before_validation :prepare_options

      validates_with PollOptionsValidator
    end
  end

  def loaded_options
    options.map.with_index do |title, key|
      Option.new(self, key.to_s, title, vote_total_for(key))
    end
  end

  class Option < ActiveModelSerializers::Model
    attributes :id, :title, :votes_count, :poll

    def initialize(poll, id, title, votes_count)
      super(poll:, id:, title:, votes_count:)
    end
  end

  private

  def prepare_options
    self.options = options.map(&:strip).compact_blank
  end

  def vote_total_for(key)
    show_totals_now? ? cached_tallies[key].presence.to_i : nil
  end
end
