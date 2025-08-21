# frozen_string_literal: true

class UnallowDomainService < BaseService
  def call(domain_allow)
    suspend_accounts!(domain_allow.domain) if Rails.configuration.x.mastodon.limited_federation_mode

    domain_allow.destroy
  end

  private

  def suspend_accounts!(domain)
    Account.where(domain: domain).in_batches.touch_all(:suspended_at)
    AfterUnallowDomainWorker.perform_async(domain)
  end
end
