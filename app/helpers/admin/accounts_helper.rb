# frozen_string_literal: true

module Admin::AccountsHelper
  def admin_accounts_moderation_options
    [
      [t('admin.accounts.moderation.active'), 'active'],
      [t('admin.accounts.moderation.silenced'), 'silenced'],
      [t('admin.accounts.moderation.disabled'), 'disabled'],
      [t('admin.accounts.moderation.suspended'), 'suspended'],
      [safe_join([t('admin.accounts.moderation.pending'), "(#{pending_user_count_label})"], ' '), 'pending'],
    ]
  end

  def account_security_actions(account)
    [].tap do |actions|
      if account.user&.two_factor_enabled? && can?(:disable_2fa, account.user)
        actions << table_link_to(
          'lock_open',
          t('admin.accounts.disable_two_factor_authentication'),
          admin_user_two_factor_authentication_path(account.user.id),
          method: :delete
        )
      elsif account.user&.suspicious_inactive_sign_in? && can?(:disable_sign_in_token, account.user)
        actions << table_link_to(
          'lock_open',
          t('admin.accounts.disable_sign_in_token'),
          admin_user_sign_in_token_authentication_path(account.user.id),
          method: :delete, data: { confirm: t('admin.accounts.are_you_sure') }
        )
      elsif account.user&.sign_in_token_disabled? && can?(:enable_sign_in_token, account.user)
        actions << table_link_to(
          'lock',
          t('admin.accounts.enable_sign_in_token'),
          admin_user_sign_in_token_authentication_path(account.user.id),
          method: :post, data: { confirm: t('admin.accounts.are_you_sure') }
        )
      end

      if can?(:reset_password, account.user)
        actions << table_link_to(
          'key', t('admin.accounts.reset_password'),
          admin_account_reset_path(account.id),
          method: :post, data: { confirm: t('admin.accounts.are_you_sure') }
        )
      end
    end
  end

  private

  def pending_user_count_label
    number_with_delimiter User.pending.count
  end
end
