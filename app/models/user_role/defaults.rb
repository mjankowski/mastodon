# frozen_string_literal: true

module UserRole::Defaults
  extend ActiveSupport::Concern

  EVERYONE_ROLE_ID = -99
  NOBODY_POSITION = -1

  included do
    before_validation :set_position
  end

  class_methods do
    def nobody
      @nobody ||= UserRole.new(permissions: UserRole::Flags::NONE, position: NOBODY_POSITION)
    end

    def everyone
      UserRole.find(EVERYONE_ROLE_ID)
    rescue ActiveRecord::RecordNotFound
      UserRole.create!(id: EVERYONE_ROLE_ID, permissions: UserRole::Flags::DEFAULT)
    end
  end

  def nobody?
    id.nil?
  end

  def everyone?
    id == EVERYONE_ROLE_ID
  end

  private

  def set_position
    self.position = NOBODY_POSITION if everyone?
  end
end
