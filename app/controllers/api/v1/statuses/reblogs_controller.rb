# frozen_string_literal: true

class Api::V1::Statuses::ReblogsController < Api::V1::Statuses::BaseController
  include Redisable
  include Lockable

  before_action -> { doorkeeper_authorize! :write, :'write:statuses' }
  before_action :require_user!
  before_action :set_reblog, only: [:create]
  before_action :set_reblog_status, only: :destroy
  skip_before_action :set_status

  override_rate_limit_headers :create, family: :statuses

  def create
    with_redis_lock("reblog:#{current_account.id}:#{@reblog.id}") do
      @status = ReblogService.new.call(current_account, @reblog, reblog_params)
    end

    render json: @status, serializer: REST::StatusSerializer
  end

  def destroy
    if @status
      authorize @status, :unreblog?
      @reblog = @status.reblog
      count = adjusted_count
      @status.discard
      RemovalWorker.perform_async(@status.id)
    else
      @reblog = Status.find(params[:status_id])
      count = @reblog.reblogs_count
      authorize @reblog, :show?
    end

    render json: @reblog, serializer: REST::StatusSerializer, relationships: relationships(count)
  rescue Mastodon::NotPermittedError
    not_found
  end

  private

  def set_reblog
    @reblog = Status.find(params[:status_id])
    authorize @reblog, :show?
  rescue Mastodon::NotPermittedError
    not_found
  end

  def set_reblog_status
    @status = current_account.statuses.find_by(reblog_of_id: params[:status_id])
  end

  def reblog_params
    params.permit(:visibility)
  end

  def adjusted_count
    [@reblog.reblogs_count - 1, 0].max
  end

  def relationships(count)
    StatusRelationshipsPresenter.new(
      [@status],
      current_account.id,
      reblogs_map: { @reblog.id => false },
      attributes_map: { @reblog.id => { reblogs_count: count } }
    )
  end
end
