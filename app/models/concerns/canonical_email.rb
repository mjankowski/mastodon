# frozen_string_literal: true

module CanonicalEmail
  extend ActiveSupport::Concern

  included do
    normalizes :canonical_email_hash, with: ->(value) { Digest::SHA256.hexdigest(value) }
    normalizes :email, with: ->(value) { canonicalize(value) }
  end

  class_methods do
    def canonicalize(email)
      email.downcase
           .split('@', 2)
           .then { |user, host| [canonical_user(user), host] }
           .join('@')
    end

    def canonical_user(user)
      user.delete('.')
          .split('+', 2)
          .first
    end
  end

  def email=(email)
    super
    self.canonical_email_hash = self.email
  end
end
