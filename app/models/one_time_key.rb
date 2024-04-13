# frozen_string_literal: true

class OneTimeKey < ApplicationRecord
  belongs_to :device

  validates :key_id, :key, :signature, presence: true
  validates :key, ed25519_key: true
  validates :signature, ed25519_signature: { message: :key, verify_key: ->(one_time_key) { one_time_key.device.fingerprint_key } }
end
