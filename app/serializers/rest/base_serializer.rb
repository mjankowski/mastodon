# frozen_string_literal: true

class REST::BaseSerializer < Oj::Serializer
  sort_attributes_by :name

  def current_user
    options[:current_user]
  end

  def current_user?
    !current_user.nil?
  end
end
