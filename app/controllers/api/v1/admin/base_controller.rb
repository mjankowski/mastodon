# frozen_string_literal: true

class Api::V1::Admin::BaseController < Api::BaseController
  include Authorization
  include AccountableConcern

  before_action do
    Rails.event.set_context account_id: current_account&.id
  end
end
