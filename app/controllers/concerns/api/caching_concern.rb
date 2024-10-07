# frozen_string_literal: true

module Api::CachingConcern
  extend ActiveSupport::Concern

  def cache_if_unauthenticated!
    public_cache_control unless user_signed_in?
  end

  def cache_even_if_authenticated!
    public_cache_control(expires: 5.minutes) unless limited_federation_mode?
  end
end
