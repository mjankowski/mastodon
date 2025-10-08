# frozen_string_literal: true

class CanonicalEmailBlock < ApplicationRecord
  include CanonicalEmail
  include Paginable

  belongs_to :reference_account, class_name: 'Account', optional: true

  validates :canonical_email_hash, presence: true, uniqueness: true

  scope :matching_email, ->(email) { where(canonical_email_hash: digest(normalize_value_for(:email, email))) }

  alias_attribute :to_log_human_identifier, :canonical_email_hash

  def self.block?(email)
    matching_email(email).exists?
  end

  def self.digest(value)
    Digest::SHA256.hexdigest(value)
  end

  def email=(email)
    super
    self.canonical_email_hash = self.class.digest(self.email)
  end
end
