# frozen_string_literal: true

class Admin::AccountActionService < BaseService
  include AccountableConcern
  include Authorization

  attr_reader :account_action, :current_account

  def call(account_action, current_account)
    @account_action = account_action
    @current_account = current_account

    process_action!
  end

  private

  delegate :target_account,
           :type,
           to: :account_action

  def process_action!
    case type
    when 'disable'
      handle_disable!
    when 'sensitive'
      handle_sensitive!
    when 'silence'
      handle_silence!
    when 'suspend'
      handle_suspend!
    end
  end

  def handle_disable!
    authorize(target_account.user, :disable?)
    log_action(:disable, target_account.user)
    target_account.user&.disable!
  end

  def handle_sensitive!
    authorize(target_account, :sensitive?)
    log_action(:sensitive, target_account)
    target_account.sensitize!
  end

  def handle_silence!
    authorize(target_account, :silence?)
    log_action(:silence, target_account)
    target_account.silence!
  end

  def handle_suspend!
    authorize(target_account, :suspend?)
    log_action(:suspend, target_account)
    target_account.suspend!(origin: :local)
  end
end
