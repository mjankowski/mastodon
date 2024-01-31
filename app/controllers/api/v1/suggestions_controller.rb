# frozen_string_literal: true

class Api::V1::SuggestionsController < Api::BaseController
  include Authorization

  before_action -> { doorkeeper_authorize! :read, :'read:accounts' }, only: :index
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }, except: :index
  before_action :require_user!
  before_action :set_suggestions

  def index
    render json: REST::AccountSerializer.many(
      # TODO: to helper
      @suggestions.get(limit_param(DEFAULT_ACCOUNTS_LIMIT), params[:offset].to_i).map(&:account)
    )
  end

  def destroy
    @suggestions.remove(params[:id])
    render_empty
  end

  private

  def set_suggestions
    @suggestions = AccountSuggestions.new(current_account)
  end
end
