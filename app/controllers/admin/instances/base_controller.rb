# frozen_string_literal: true

module Admin
  module Instances
    class BaseController < Admin::BaseController
      before_action :set_instance

      private

      def set_instance
        @instance = Instance.find_or_initialize_by(domain: instance_domain)
      end

      def instance_domain
        TagManager.instance.normalize_domain(params[:instance_id]&.strip)
      end
    end
  end
end
