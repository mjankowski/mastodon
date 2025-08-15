# frozen_string_literal: true

# == Schema Information
#
# Table name: invites
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  code       :string           default(""), not null
#  expires_at :datetime
#  max_uses   :integer
#  uses       :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  autofollow :boolean          default(FALSE), not null
#  comment    :text
#

class Invite < ApplicationRecord
  include Expireable

  CODE_LENGTH = 8
  COMMENT_SIZE_LIMIT = 420
  ELIGIBLE_CODE_CHARACTERS = [*('a'..'z'), *('A'..'Z'), *('0'..'9')].freeze
  HOMOGLYPHS = %w(0 1 I l O).freeze
  VALID_CODE_CHARACTERS = ELIGIBLE_CODE_CHARACTERS - HOMOGLYPHS

  belongs_to :user, inverse_of: :invites
  has_many :users, inverse_of: :invite, dependent: nil

  scope :available, -> { where(expires_at: nil).or(where(expires_at: Time.now.utc..)) }

  validates :comment, length: { maximum: COMMENT_SIZE_LIMIT }

  before_validation :set_code, on: :create

  delegate :functional?, allow_nil: true, prefix: true, to: :user

  def valid_for_use?
    usable? && !!user_functional?
  end

  private

  def usable?
    under_usage_limit? && !expired?
  end

  def under_usage_limit?
    max_uses.blank? || uses < max_uses
  end

  def set_code
    loop do
      self.code = VALID_CODE_CHARACTERS.sample(CODE_LENGTH).join
      break unless Invite.exists?(code:)
    end
  end
end
