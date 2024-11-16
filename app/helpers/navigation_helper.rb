# frozen_string_literal: true

module NavigationHelper
  def navigation_shows_software_updates?
    Rails.configuration.x.mastodon.software_update_url.present? &&
      current_user.can?(:view_devops) &&
      SoftwareUpdate.urgent_pending?
  end

  def navigation_shows_invites?
    current_user.can?(:invite_users) &&
      current_user.functional?
  end

  def navigation_shows_moderation?
    current_user.can?(:manage_reports, :view_audit_log, :manage_users, :manage_invites, :manage_taxonomies, :manage_federation, :manage_blocks)
  end

  def navigation_shows_admin?
    current_user.can?(:view_dashboard, :manage_settings, :manage_rules, :manage_announcements, :manage_custom_emojis, :manage_webhooks, :manage_federation)
  end
end
