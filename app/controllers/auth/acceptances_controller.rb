# frozen_string_literal: true

class Auth::AcceptancesController < ApplicationController
  def create
    session[:rules_accepted] = true
    redirect_to new_user_registration_path(registration_params)
  end

  private

  def registration_params
    params.permit(:invite_code).compact_blank
  end
end
