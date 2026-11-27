# frozen_string_literal: true

module Admin
  class ActionLogsController < BaseController
    before_action :set_action_logs

    def index
      authorize :audit_log, :index?
      @auditable_accounts = Account.auditable.select(:id, :username).order(username: :asc)
    end

    private

    def set_action_logs
      @action_logs = Admin::ActionLogFilter.new(filter_params).results.page(params[:page])
    end

    def filter_params
      params.slice(:page, *Admin::ActionLogFilter::KEYS).permit(:page, *Admin::ActionLogFilter::KEYS).tap do |permitted_params|
        next unless permitted_params.key?(:target_type)

        action_type = Admin::ActionLogFilter::ACTION_TYPE_MAP[permitted_params[:action_type]&.to_sym]
        permitted_params.delete(:action_type) if action_type && action_type[:target_type] != permitted_params[:target_type]
      end
    end
  end
end
