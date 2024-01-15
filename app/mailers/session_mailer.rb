# frozen_string_literal: true

class SessionMailer < ApplicationMailer
  helper :routing
  helper :formatting

  before_action :set_instance
  before_action :set_user

  default to: -> { @user.email }

  def welcome
    return unless @user.active_for_authentication?

    I18n.with_locale(locale) do
      # TODO: Restore `default_i18n_subject` after full mailer move
      mail subject: t('user_mailer.welcome.subject') # default_i18n_subject
    end
  end

  def suspicious_sign_in(remote_ip, user_agent, timestamp)
    @remote_ip  = remote_ip
    @user_agent = user_agent
    @detection  = Browser.new(user_agent)
    @timestamp  = timestamp.to_time.utc

    I18n.with_locale(locale) do
      # TODO: Restore `default_i18n_subject` after full mailer move
      mail subject: t('user_mailer.suspicious_sign_in.subject') # default_i18n_subject
    end
  end

  private

  def set_user
    @user = params[:user]
  end

  def set_instance
    @instance = Rails.configuration.x.local_domain
  end

  def locale
    @user.locale.presence || I18n.default_locale
  end
end
