# frozen_string_literal: true

module Admin
  module Instances
    class Delivery::PausesController < BaseController
      def create
        authorize :delivery, :stop_delivery?

        unavailable_domain = UnavailableDomain.create!(domain: @instance.domain)
        log_action :create, unavailable_domain

        redirect_to admin_instance_path(@instance.domain)
      end

      def destroy
        authorize :delivery, :restart_delivery?

        if @instance.unavailable?
          @instance.delivery_failure_tracker.track_success!
          log_action :destroy, @instance.unavailable_domain
        end

        redirect_to admin_instance_path(@instance.domain)
      end
    end
  end
end
