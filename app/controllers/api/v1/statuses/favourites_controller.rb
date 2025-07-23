# frozen_string_literal: true

class Api::V1::Statuses::FavouritesController < Api::V1::Statuses::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:favourites' }
  before_action :require_user!
  skip_before_action :set_status, only: [:destroy]

  def create
    FavouriteService.new.call(current_account, @status)
    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    if favourite
      @status = favourite.status
      count = adjusted_count
      UnfavouriteWorker.perform_async(current_account.id, @status.id)
    else
      @status = Status.find(params[:status_id])
      count = @status.favourites_count
      authorize @status, :show?
    end

    render json: @status, serializer: REST::StatusSerializer, relationships: relationships(count)
  rescue Mastodon::NotPermittedError
    not_found
  end

  private

  def favourite
    @favourite ||= current_account.favourites.find_by(status_id: params[:status_id])
  end

  def relationships(count)
    StatusRelationshipsPresenter.new(
      [@status],
      current_account.id,
      favourites_map: { @status.id => false },
      attributes_map: { @status.id => { favourites_count: count } }
    )
  end

  def adjusted_count
    [@status.favourites_count - 1, 0].max
  end
end
