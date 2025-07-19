# frozen_string_literal: true

module Admin::BatchActions
  extend ActiveSupport::Concern

  included do
    class_attribute :available_batch_actions
  end

  class_methods do
    def allow_batch_operation(actions:)
      self.available_batch_actions = actions
    end
  end

  def action_from_button
    available_batch_actions
      .to_a
      .detect { |action| params[action] }
      .to_s
      .presence
  end
end
