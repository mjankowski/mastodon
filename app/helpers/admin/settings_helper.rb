# frozen_string_literal: true

module Admin::SettingsHelper
  def captcha_available?
    Rails.configuration.x.captcha.secret_key.present? && Rails.configuration.x.captcha.site_key.present?
  end

  def login_activity_title(activity)
    t(
      "login_activities.#{login_activity_key(activity)}",
      method: login_activity_method(activity),
      ip: login_activity_ip(activity),
      browser: login_activity_browser(activity)
    )
  end

  def admin_settings_links
    proc do |menu|
      menu.item :branding, safe_join([material_symbol('edit'), t('admin.settings.branding.title')]), admin_settings_branding_path
      menu.item :about, safe_join([material_symbol('description'), t('admin.settings.about.title')]), admin_settings_about_path
      menu.item :registrations, safe_join([material_symbol('group'), t('admin.settings.registrations.title')]), admin_settings_registrations_path
      menu.item :discovery, safe_join([material_symbol('search'), t('admin.settings.discovery.title')]), admin_settings_discovery_path
      menu.item :content_retention, safe_join([material_symbol('history'), t('admin.settings.content_retention.title')]), admin_settings_content_retention_path
      menu.item :appearance, safe_join([material_symbol('computer'), t('admin.settings.appearance.title')]), admin_settings_appearance_path
    end
  end

  private

  def login_activity_key(activity)
    activity.success? ? 'successful_sign_in_html' : 'failed_sign_in_html'
  end

  def login_activity_method(activity)
    content_tag(
      :span,
      login_activity_method_string(activity),
      class: 'target'
    )
  end

  def login_activity_ip(activity)
    content_tag(
      :span,
      activity.ip,
      class: 'target'
    )
  end

  def login_activity_browser(activity)
    content_tag(
      :span,
      login_activity_browser_description(activity),
      class: 'target',
      title: activity.user_agent
    )
  end

  def login_activity_method_string(activity)
    if activity.omniauth?
      t("auth.providers.#{activity.provider}")
    else
      t("login_activities.authentication_methods.#{activity.authentication_method}")
    end
  end

  def login_activity_browser_description(activity)
    t(
      'sessions.description',
      browser: t(activity.browser, scope: 'sessions.browsers', default: activity.browser.to_s),
      platform: t(activity.platform, scope: 'sessions.platforms', default: activity.platform.to_s)
    )
  end
end
