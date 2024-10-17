# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    TIME_PERIOD_RANGE = 29.days

    include Redisable

    def index
      authorize :dashboard, :index?

      @pending_appeals_count = Appeal.pending.async_count
      @pending_reports_count = Report.unresolved.async_count
      @pending_tags_count = Tag.pending_review.async_count
      @pending_users_count = User.pending.async_count
      @system_checks = Admin::SystemCheck.perform(current_user)
      @time_period = (TIME_PERIOD_RANGE.ago.to_date...Time.now.utc.to_date)
    end
  end
end
