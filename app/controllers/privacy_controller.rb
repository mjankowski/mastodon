# frozen_string_literal: true

class PrivacyController < ApplicationController
  include WebAppControllerConcern

  skip_before_action :require_functional!

  def show
    public_cache_control unless user_signed_in?
  end
end
