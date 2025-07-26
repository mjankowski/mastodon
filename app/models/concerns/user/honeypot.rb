# frozen_string_literal: true

module User::Honeypot
  extend ActiveSupport::Concern

  included do
    # These are "honeypot" fields used for anti-spam only. They appear on the
    # registration form, but will only be filled out by bots. We require their
    # absence, and consider a user being created with the fields to be invalid.

    attr_accessor :confirm_password,
                  :website

    with_options absence: true, on: :create do
      validates :confirm_password
      validates :website
    end
  end
end
