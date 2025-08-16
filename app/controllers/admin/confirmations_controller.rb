# frozen_string_literal: true

module Admin
  class ConfirmationsController < BaseController
    before_action :set_user

    def create
      authorize @user, :confirm?
      @user.mark_email_as_confirmed!
      log_action :confirm, @user
      redirect_to admin_accounts_path
    end
  end
end
