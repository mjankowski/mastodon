# frozen_string_literal: true

module Admin
  module Instances
    class Delivery::ErrorsController < BaseController
      def destroy
        authorize :delivery, :clear_delivery_errors?

        @instance.delivery_failure_tracker.clear_failures!

        redirect_to admin_instance_path(@instance.domain)
      end
    end
  end
end
