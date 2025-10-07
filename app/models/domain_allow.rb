# frozen_string_literal: true

class DomainAllow < ApplicationRecord
  include Paginable
  include DomainNormalizable
  include DomainMaterializable

  validates :domain, presence: true, uniqueness: true, domain: true

  alias_attribute :to_log_human_identifier, :domain

  class << self
    def allowed?(domain)
      !rule_for(domain).nil?
    end

    def allowed_domains
      pluck(:domain)
    end

    def rule_for(domain)
      return if domain.blank?

      uri = Addressable::URI.new.tap { |u| u.host = domain.strip.delete('/') }

      find_by(domain: uri.normalized_host)
    end
  end
end
