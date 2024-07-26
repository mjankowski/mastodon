# frozen_string_literal: true

module Admin
  class ActionLogsController < BaseController
    before_action :set_action_logs

    def index
      authorize :audit_log, :index?
      @auditable_accounts = Account.auditable.select(:id, :username)
    end

    private

    def set_action_logs
      @page, @action_logs = pagy(Admin::ActionLogFilter.new(filter_params).results)
    end

    def filter_params
      params.slice(:page, *Admin::ActionLogFilter::KEYS).permit(:page, *Admin::ActionLogFilter::KEYS)
    end
  end
end
