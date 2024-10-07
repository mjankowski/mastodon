# frozen_string_literal: true

class HomeController < ApplicationController
  include WebAppControllerConcern

  def index
    public_cache_control unless user_signed_in?
  end
end
