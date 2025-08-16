# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    before_action :set_instances, only: :index
    before_action :set_instance, except: :index

    LOGS_LIMIT = 5

    def index
      authorize :instance, :index?
      preload_delivery_failures!
    end

    def show
      authorize :instance, :show?

      @instance_moderation_note = @instance.moderation_notes.new
      @instance_moderation_notes = @instance.moderation_notes.includes(:account).chronological
      @time_period = (6.days.ago.to_date...Time.now.utc.to_date)
      @action_logs = Admin::ActionLogFilter.new(target_domain: @instance.domain).results.limit(LOGS_LIMIT)
    end

    def destroy
      authorize :instance, :destroy?
      Admin::DomainPurgeWorker.perform_async(@instance.domain)
      log_action :destroy, @instance
      redirect_to admin_instances_path, notice: I18n.t('admin.instances.destroyed_msg', domain: @instance.domain)
    end

    private

    def set_instance
      domain = params[:id]&.strip
      @instance = Instance.find_or_initialize_by(domain: TagManager.instance.normalize_domain(domain))
    end

    def set_instances
      @instances = filtered_instances.page(params[:page])
    end

    def preload_delivery_failures!
      warning_domains_map = DeliveryFailureTracker.warning_domains_map(@instances.map(&:domain))

      @instances.each do |instance|
        instance.failure_days = warning_domains_map[instance.domain]
      end
    end

    def filtered_instances
      InstanceFilter.new(limited_federation_mode? ? { allowed: true } : filter_params).results
    end

    def filter_params
      params.slice(*InstanceFilter::KEYS).permit(*InstanceFilter::KEYS)
    end
  end
end
