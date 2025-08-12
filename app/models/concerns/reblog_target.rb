# frozen_string_literal: true

module ReblogTarget
  extend ActiveSupport::Concern

  included do
    before_validation :target_status_reblogs, if: -> { status&.reblog? }
  end

  private

  def target_status_reblogs
    self.status = status.reblog
  end
end
