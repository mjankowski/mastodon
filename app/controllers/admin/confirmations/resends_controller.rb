# frozen_string_literal: true

module Admin
  class Confirmations::ResendsController < BaseController
    before_action :set_user
    before_action :redirect_confirmed_user, if: :user_confirmed?

    def create
      authorize @user, :confirm?

      @user.resend_confirmation_instructions

      log_action :resend, @user

      redirect_to admin_accounts_path, notice: t('admin.accounts.resend_confirmation.success')
    end

    private

    def redirect_confirmed_user
      redirect_to admin_accounts_path, flash: { error: t('admin.accounts.resend_confirmation.already_confirmed') }
    end

    def user_confirmed?
      @user.confirmed?
    end
  end
end
